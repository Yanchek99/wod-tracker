module CfWod
  class AscendingLadderInferer
    ETC = /\AEtc\.?\z/i

    def self.call(parsed_lines) = new(parsed_lines).infer

    def initialize(parsed_lines)
      @parsed_lines = parsed_lines
    end

    def infer
      exercise_lines = extract_exercise_lines
      rung_width = determine_rung_width(exercise_lines)
      rungs = build_rungs(exercise_lines, rung_width)
      first_rung = rungs.first
      validate_rung_movements!(rungs, first_rung)

      { ladder_step: calculate_ladder_step(rungs), lines: first_rung }
    end

    private

    attr_reader :parsed_lines

    def extract_exercise_lines
      raise_ambiguous('missing final Etc. line') unless parsed_lines.last&.fetch(:raw_line, '').to_s.match?(ETC)

      exercise_lines = parsed_lines[0...-1]
      valid_lines = exercise_lines.all? do |line|
        line.dig(:attrs, :movement_name).present? && line.dig(:attrs, :reps).is_a?(Integer)
      end
      raise_ambiguous('exercise lines must include movement names and integer reps') unless valid_lines

      exercise_lines
    end

    def determine_rung_width(exercise_lines)
      movement_names = exercise_lines.map { |line| line.dig(:attrs, :movement_name) }
      rung_width = movement_names.each_index.find do |index|
        movement_names[0...index].include?(movement_names[index])
      end
      raise_ambiguous('requires at least two complete rungs') unless rung_width&.positive?

      rung_width
    end

    def build_rungs(exercise_lines, rung_width)
      valid_rung_count = exercise_lines.length >= rung_width * 2 && (exercise_lines.length % rung_width).zero?
      raise_ambiguous('requires at least two complete rungs') unless valid_rung_count

      exercise_lines.each_slice(rung_width).to_a
    end

    def validate_rung_movements!(rungs, first_rung)
      first_movement_names = first_rung.map { |line| line.dig(:attrs, :movement_name) }
      matching_movements = rungs.all? do |rung|
        rung.map { |line| line.dig(:attrs, :movement_name) } == first_movement_names
      end
      raise_ambiguous('movement sequence changes between rungs') unless matching_movements
    end

    def calculate_ladder_step(rungs)
      deltas = rungs.each_cons(2).flat_map do |previous_rung, next_rung|
        previous_rung.zip(next_rung).map do |previous_line, next_line|
          next_line.dig(:attrs, :reps) - previous_line.dig(:attrs, :reps)
        end
      end
      raise_ambiguous('rep step is not constant and increasing across rungs') unless deltas.uniq.one? && deltas.first&.positive?

      deltas.first
    end

    def raise_ambiguous(reason)
      raise WorkoutParser::UnparseableError, "ambiguous ascending ladder ending in Etc.: #{reason}"
    end
  end
end
