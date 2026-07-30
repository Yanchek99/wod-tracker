class SugarwodImport
  class BarbellLiftHeader
    SET_SCHEME_IN_TITLE = /(\d+)\s*x\s*(\d+)\z/i
    SET_OF_N = /set of (\d+)/i
    SINGLE = /single\b/i
    DEFAULT_REPS = 1

    def self.call(row) = new(row).synthesized_text

    def initialize(row)
      @row = row
    end

    def synthesized_text
      "Find a #{rep_count}-rep-max #{row[:barbell_lift].to_s.strip}"
    end

    private

    attr_reader :row

    def rep_count
      from_title_set_scheme || from_description_set_of || from_description_single || DEFAULT_REPS
    end

    def from_title_set_scheme
      match = row[:title].to_s.strip.match(SET_SCHEME_IN_TITLE)
      match && match[2].to_i
    end

    def from_description_set_of
      match = row[:description].to_s.match(SET_OF_N)
      match && match[1].to_i
    end

    def from_description_single
      DEFAULT_REPS if row[:description].to_s.match?(SINGLE)
    end
  end
end
