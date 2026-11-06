class SugarwodImport
  class NameMatcher
    OPEN_NUMBER = /\b(\d{2})\.(\d+|zero|one|two|three|four|five|six|seven|eight|nine)\b/i
    STAGE_WORD = /\b(open|quarterfinals?|regionals?|semifinals?)\b/i
    WORD_TO_DIGIT = {
      'zero' => '0', 'one' => '1', 'two' => '2', 'three' => '3', 'four' => '4',
      'five' => '5', 'six' => '6', 'seven' => '7', 'eight' => '8', 'nine' => '9'
    }.freeze

    # SugarWOD's export uses several historical titles for an Open workout that was later reused
    # verbatim as a different year's number -- the seed file (db/seeds/open_workouts.rb) already
    # documents each of these as a "# NN.M is a repeat of ..." comment rather than duplicating the
    # Workout row, so a lifter's PRs under either title land on the same catalog entry. This table
    # is the import-time counterpart to those comments.
    REPEATS = {
      '19.2' => 'Open 16.2',
      '21.2' => 'Open 17.1',
      '23.1' => 'Open 14.4'
    }.freeze

    def self.call(title) = new(title).match

    def initialize(title)
      @title = title.to_s.strip
    end

    def match
      exact_match || flattened_match || repeat_match || open_number_match
    end

    private

    attr_reader :title

    def exact_match
      Workout.find_by('LOWER(name) = ?', title.downcase)
    end

    # SugarWOD's export sometimes wraps a named workout's title in literal quote marks
    # (e.g. `"Murph"`), and its own display name for a catalog workout can drift from ours by
    # spacing alone (e.g. "Hot Shots 19" vs our "Hotshots 19"). Comparing with everything but
    # letters and digits stripped from both sides catches these without weakening exact_match's
    # precision for the common case.
    def flattened_match
      Workout.find_by("LOWER(REGEXP_REPLACE(name, '[^a-zA-Z0-9]', '', 'g')) = ?", flattened(title))
    end

    def flattened(value)
      value.downcase.gsub(/[^a-z0-9]/, '')
    end

    def repeat_match
      return nil unless stage == 'open'

      canonical = REPEATS[number]
      Workout.find_by('LOWER(name) = ?', canonical.downcase) if canonical
    end

    # Requiring the competition-stage word to also match prevents a real collision: e.g.
    # "Quarterfinals 22.4" and "Open 22.4" are different workouts that happen to share a number.
    # A bare "NN.digit" title with no stage word at all (e.g. "18.Zero") defaults to "open",
    # preserving the original behavior for that case.
    #
    # The number itself is matched with digit boundaries on both sides (not a bare substring),
    # so "24.1" can't match a catalog entry named "24.10" -- and results are ordered so the
    # lookup is deterministic even if more than one row somehow matches.
    def open_number_match
      return nil unless number

      Workout.where('name ILIKE ?', "%#{stage}%")
             .where('name ~* ?', number_boundary_pattern)
             .order(:id)
             .first
    end

    def number_boundary_pattern
      "(^|[^0-9])#{Regexp.escape(number)}([^0-9]|$)"
    end

    def number
      captures = title.match(OPEN_NUMBER)
      return nil unless captures

      major, minor = captures.captures
      "#{major}.#{WORD_TO_DIGIT[minor.downcase] || minor}"
    end

    def stage
      match = title.match(STAGE_WORD)
      match ? match[1].downcase.delete_suffix('s') : 'open'
    end
  end
end
