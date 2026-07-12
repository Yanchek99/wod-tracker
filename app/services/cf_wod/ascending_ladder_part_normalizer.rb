module CfWod
  class AscendingLadderPartNormalizer
    ETC_LINE = /\AEtc\.?\z/i

    def self.call(workout, parts) = new(workout, parts).normalize

    def initialize(workout, parts)
      @workout = workout
      @parts = parts
    end

    def normalize
      return parts unless ladder_candidate?

      ladder = AscendingLadderInferer.call(parsed_lines)
      workout.ladder_step = ladder[:ladder_step]

      [part.merge(lines: ladder[:lines].pluck(:raw_line))]
    end

    private

    attr_reader :workout, :parts

    def ladder_candidate?
      parts.one? && !part[:segment] && part[:lines].last&.match?(ETC_LINE)
    end

    def parsed_lines
      part[:lines].map do |line|
        { raw_line: line, attrs: ExerciseLineParser.call(line) }
      end
    end

    def part
      parts.first
    end
  end
end
