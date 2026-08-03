require 'json'

class SugarwodImport
  class SetSchemeExtractor
    DASH_SCHEME = /\b(\d+(?:-\d+){2,})\b/
    AXB_SCHEME = /(\d+)\s*x\s*(\d+)\z/i
    SET_OF_N = /set of (\d+)/i
    SINGLE = /single\b/i
    TRAILING_NOTE = /(?:Rest\s*As\s*Needed.*|Rest\s*\d+.*)\z/i

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
      @details ||= begin
        JSON.parse(row[:set_details].to_s)
      rescue JSON::ParserError
        []
      end
    end

    def successful_details
      details.reject { |detail| detail['success'] == false }
    end

    # A blank/missing load must never be coerced to 0 -- a successful set with no recorded load
    # would otherwise become a real zero-load MovementLog, fabricating a PR that never happened.
    def parsed_load(detail)
      load = detail['load']
      return nil if load.blank?

      Integer(load.to_s, exception: false)
    end

    def rep_scheme
      dash_scheme || axb_scheme || set_of_n_scheme || single_scheme || default_single_set_scheme
    end

    def dash_scheme
      match = scheme_source.match(DASH_SCHEME)
      match && match[1].split('-').map(&:to_i)
    end

    def axb_scheme
      match = row[:title].to_s.strip.match(AXB_SCHEME)
      return nil unless match

      sets, reps = match.captures.map(&:to_i)
      Array.new(sets, reps) if sets == details.size
    end

    def set_of_n_scheme
      match = row[:description].to_s.match(SET_OF_N)
      Array.new(details.size, match[1].to_i) if match
    end

    def single_scheme
      Array.new(details.size, 1) if row[:description].to_s.match?(SINGLE)
    end

    def default_single_set_scheme
      [1] if details.size == 1
    end

    def scheme_source
      "#{row[:title]} #{row[:description]}".sub(TRAILING_NOTE, '').strip
    end
  end
end
