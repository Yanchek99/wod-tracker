require 'json'

class SugarwodImport
  class SetSchemeExtractor
    # Both boundaries are digit-specific lookarounds, not \b: real rows glue text directly onto
    # the scheme with no space on either side (e.g. "Load2-2-2-2-2-2-2-2Box Squat"), and \b can't
    # match between two word characters -- letters and digits are both \w. A leading \b would
    # silently start the match one digit late (dropping the first rep from the count); a trailing
    # \b would silently backtrack to a shorter sequence. Each lookaround only needs to rule out
    # continuing/starting into another digit, which is the only thing that would actually change
    # the scheme's meaning.
    DASH_SCHEME = /(?<!\d)(\d+(?:-\d+){2,})(?!-?\d)/
    AXB_SCHEME = /(\d+)\s*x\s*(\d+)\z/i
    SET_OF_N = /sets?\s+of\s+(\d+)/i
    # "1-rep max" is included here, not just "single": every attempt in a build-up toward a 1RM
    # is definitionally one rep, regardless of how many attempts are logged -- unlike "Build to a
    # 3 rep max" (REP_MAX below), where only the final logged attempt is actually N reps.
    SINGLE = /single\b|1[\s-]*rep\s+max\b/i
    # Scheme language earlier strategies failed to parse; blocks default_single_set_scheme's fallback.
    UNRECOGNIZED_SCHEME_SIGNAL = /\d+\s*(?:x|reps?|sets?)\b/i
    # The (?!\d) guards the first capture the same way DASH_SCHEME's lookarounds do above: without
    # it, a plain interval count with no real "sets: reps" scheme after it (e.g. "On the Minute x
    # 10 (5 Rounds): Minute 1: ...") lets \d+ backtrack and split "10" into captures "1" and "0",
    # fabricating a false "1 set of 0 reps" scheme instead of failing to match at all.
    INTERVAL_SCHEME = /on the (?:minute|\d+:\d+) x\s*(\d+)(?!\d)(?:\s*sets?)?\s*:?\s*(\d+)/i
    ROUNDS_SCHEME = /(\d+)\s*rounds?\s*:\s*(\d+)\b/i
    SETS_FOR_LOAD_SCHEME = /(\d+)\s*sets?\s+for\s+load\s*:\s*(\d+)\b/i
    TRAILING_NOTE = /(?:Rest\s*As\s*Needed.*|Rest\s*\d+.*)\z/i
    WAVE_MARKER = /wave\s*#?\d+\s*:?\s*/i
    WAVE_REPS = /(\d+)\s*[A-Za-z][\w-]*/
    LABELED_SET = /set\s*\d+\s*(?:\([^)]*\))?\s*:\s*(\d+)/i
    PERCENTAGE_SET = /(\d+)\s*reps?\s*@\s*\d+/i
    REP_MAX = /(\d+)[\s-]*reps?\s+max\b/i
    SCAN_SCHEMES = [LABELED_SET, PERCENTAGE_SET].freeze
    # AXB_SCHEME ("Back Squat 3x5") is a title-only convention; the others can appear in either
    # title or description. All are otherwise the same shape: a captured (sets, reps) pair,
    # applied uniformly once the stated set count matches the logged set_details count.
    UNIFORM_SET_SCHEMES = [
      [AXB_SCHEME, :title], [INTERVAL_SCHEME, :scheme_source], [ROUNDS_SCHEME, :scheme_source],
      [SETS_FOR_LOAD_SCHEME, :scheme_source]
    ].freeze
    REP_SCHEME_STRATEGIES = %i[
      dash_scheme uniform_set_scheme set_of_n_scheme single_scheme wave_scheme
      scanned_scheme default_single_set_scheme
    ].freeze

    def self.call(row) = new(row).extract

    def initialize(row)
      @row = row
    end

    def extract
      return nil if successful_details.blank?

      scheme = rep_scheme
      return nil unless scheme && scheme.size == details.size

      scheme.zip(details).filter_map do |reps, detail|
        next if detail['success'] == false

        load = parsed_load(detail)
        return nil if load.nil?

        { reps: reps, load: load }
      end
    end

    private

    attr_reader :row

    def details
      @details ||= JSON.parse(row[:set_details].to_s)
    rescue JSON::ParserError
      @details = []
    end

    def successful_details = details.reject { |detail| detail['success'] == false }

    # A blank/missing load must never be coerced to 0 -- a successful set with no recorded load
    # would otherwise become a real zero-load MovementLog, fabricating a PR that never happened.
    def parsed_load(detail)
      load = detail['load']
      load.blank? ? nil : Integer(load.to_s, exception: false)
    end

    def rep_scheme
      REP_SCHEME_STRATEGIES.each do |strategy|
        result = send(strategy)
        return result if result
      end
      nil
    end

    def dash_scheme = scheme_source.match(DASH_SCHEME)&.then { |m| m[1].split('-').map(&:to_i) }

    def uniform_set_scheme
      UNIFORM_SET_SCHEMES.each do |pattern, source|
        text = source == :title ? row[:title].to_s.strip : scheme_source
        match = text.match(pattern)
        next unless match

        sets, reps = match.captures.map(&:to_i)
        return Array.new(details.size, reps) if sets == details.size
      end
      nil
    end

    def set_of_n_scheme
      match = row[:description].to_s.match(SET_OF_N)
      Array.new(details.size, match[1].to_i) if match
    end

    def single_scheme = (Array.new(details.size, 1) if row[:description].to_s.match?(SINGLE))

    # "Build to a 3 rep max" describes one top set of N reps; otherwise default to a heavy single
    # unless the text still contains an unparsed scheme signal (never guess past real language).
    def default_single_set_scheme
      return unless details.size == 1

      match = scheme_source.match(REP_MAX)
      return [match[1].to_i] if match

      [1] unless scheme_source.match?(UNRECOGNIZED_SCHEME_SIGNAL)
    end

    def wave_scheme
      waves = scheme_source.split(WAVE_MARKER).drop(1)
      return nil if waves.size < 2

      first_wave_reps = waves.first.scan(WAVE_REPS).map { |(reps)| reps.to_i }
      return nil if first_wave_reps.empty?

      full_scheme = first_wave_reps * waves.size
      full_scheme if full_scheme.size == details.size
    end

    # LABELED_SET and PERCENTAGE_SET are one strategy: structurally identical scans, only the pattern differs.
    def scanned_scheme
      SCAN_SCHEMES.each do |pattern|
        reps = scheme_source.scan(pattern).map { |(reps)| reps.to_i }
        return reps if reps.size == details.size
      end
      nil
    end

    def scheme_source
      "#{row[:title]} #{row[:description]}".sub(TRAILING_NOTE, '').strip
    end
  end
end
