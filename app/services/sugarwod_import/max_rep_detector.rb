class SugarwodImport
  class MaxRepDetector
    MAX_PREFIX = /\Amax (?:unbroken )?(.+)\z/i
    MAX_SUFFIX = /\A(.+?)\s*\(max reps\)\z/i

    def self.call(row) = new(row).build

    def initialize(row)
      @row = row
    end

    def build
      return nil if row[:barbell_lift].present?

      description = row[:description].to_s.strip
      name = description[MAX_PREFIX, 1] || description[MAX_SUFFIX, 1]
      return nil unless name

      movement = CfWod::MovementLookup.call(name)
      return nil unless movement && single_movement_reps_makes_sense?(movement)

      build_workout(movement)
    end

    private

    attr_reader :row

    # Any single named movement can be a legitimate "how many reps" test -- this only records a
    # rep count, never a load, so there's no ambiguity from a weightlifting movement like Wall-ball
    # Shot or Shoulder Press having no fixed weight. Monostructural movements (row/run/bike/ski) are
    # excluded because they're scored in calories/distance within a time cap via
    # MonostructuralDetector, not a bare rep count; "rest" isn't a real exercise.
    def single_movement_reps_makes_sense?(movement)
      !movement.family_monostructural? && !movement.family_rest?
    end

    def build_workout(movement)
      workout = Workout.new(score_type: :rep, name: "Max #{movement.name}")
      segment = workout.segments.build(position: 1)
      segment.exercises.build(movement: movement, position: 1, reps: 0)
      workout
    end
  end
end
