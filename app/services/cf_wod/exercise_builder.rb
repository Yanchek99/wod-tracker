module CfWod
  class ExerciseBuilder
    def initialize(format)
      @format = format
      @reasons = []
    end

    attr_reader :reasons

    def build(owner, position_value, line)
      stripped_line, inline_load = InlineLoadExtractor.extract(line)
      parsed = LineParser.parse(stripped_line)
      match = MovementMatcher.match(parsed.movement_name)
      return unmatched_movement(parsed.movement_name) unless match.movement

      exercise = owner.exercises.build(exercise_attributes(match.movement, position_value, parsed))
      ExerciseLoadAssigner.assign(exercise, inline_load) if inline_load
      exercise
    end

    def build_rest(owner, position_value, minutes)
      owner.exercises.build(movement: rest_movement, position: position_value, duration_seconds: minutes && (minutes * 60))
    end

    private

    attr_reader :format

    def unmatched_movement(movement_name)
      reasons << "Could not match movement: #{movement_name.inspect}"
      nil
    end

    def exercise_attributes(movement, position_value, parsed)
      {
        movement: movement, position: position_value,
        reps: parsed.reps || implied_interval_reps,
        calories: parsed.calories, distance: parsed.distance, distance_unit: parsed.distance_unit,
        notes: parsed.notes
      }
    end

    def implied_interval_reps
      1 if format.interval
    end

    # 'Rest' is a fixed catalog entry, not a name lifted from prose -- distinct from
    # MovementMatcher's policy of never creating movements from parsed text.
    def rest_movement
      @rest_movement ||= Movement.find_or_create_by(name: 'Rest')
    end
  end
end
