module CfWod
  class AscendingLadderInferer
    ETC = /\AEtc\.?\z/i

    def self.call(parsed_lines) = new(parsed_lines).infer

    def initialize(parsed_lines)
      @parsed_lines = parsed_lines
    end

    def infer
      raise_ambiguous unless parsed_lines.last&.fetch(:raw_line, '').to_s.match?(ETC)

      exercise_lines = parsed_lines[0...-1]
      movement_names = exercise_lines.map { |line| line.dig(:attrs, :movement_name) }
      raise_ambiguous unless exercise_lines.all? do |line|
        line.dig(:attrs, :movement_name).present? && line.dig(:attrs, :reps).is_a?(Integer)
      end

      rung_width = movement_names.each_index.find { |index| movement_names[0...index].include?(movement_names[index]) }
      raise_ambiguous unless rung_width&.positive?
      raise_ambiguous unless exercise_lines.length >= rung_width * 2 && (exercise_lines.length % rung_width).zero?

      rungs = exercise_lines.each_slice(rung_width).to_a
      first_rung = rungs.first
      raise_ambiguous unless rungs.all? { |rung| rung.map { |line| line.dig(:attrs, :movement_name) } == first_rung.map { |line| line.dig(:attrs, :movement_name) } }

      deltas = rungs.each_cons(2).flat_map do |previous_rung, next_rung|
        previous_rung.zip(next_rung).map do |previous_line, next_line|
          next_line.dig(:attrs, :reps) - previous_line.dig(:attrs, :reps)
        end
      end
      raise_ambiguous unless deltas.uniq.one? && deltas.first&.positive?

      { ladder_step: deltas.first, lines: first_rung }
    end

    private

    attr_reader :parsed_lines

    def raise_ambiguous
      raise WorkoutParser::UnparseableError, 'ambiguous ascending ladder ending in Etc.'
    end
  end
end
