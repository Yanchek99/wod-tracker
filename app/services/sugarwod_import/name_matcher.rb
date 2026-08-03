class SugarwodImport
  class NameMatcher
    OPEN_NUMBER = /\b(\d{2})\.(\d+|zero|one|two|three|four|five|six|seven|eight|nine)\b/i
    WORD_TO_DIGIT = {
      'zero' => '0', 'one' => '1', 'two' => '2', 'three' => '3', 'four' => '4',
      'five' => '5', 'six' => '6', 'seven' => '7', 'eight' => '8', 'nine' => '9'
    }.freeze

    def self.call(title) = new(title).match

    def initialize(title)
      @title = title.to_s.strip
    end

    def match
      exact_match || flattened_match || open_number_match
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

    def open_number_match
      captures = title.match(OPEN_NUMBER)
      return nil unless captures

      major, minor = captures.captures
      minor_digit = WORD_TO_DIGIT[minor.downcase] || minor
      Workout.where('name LIKE ?', "%#{major}.#{minor_digit}%").first
    end
  end
end
