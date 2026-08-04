class SugarwodImport
  class MaxDistanceDetector
    MAX_HEIGHT_COLON_SUFFIX = /\A(.+?)\s*:\s*max height\z/i

    def self.call(row) = new(row).build

    def initialize(row)
      @row = row
    end

    def build
      return nil if row[:barbell_lift].present?

      description = row[:description].to_s.strip
      name = description[MAX_HEIGHT_COLON_SUFFIX, 1]
      return nil unless name

      movement = CfWod::MovementLookup.call(name)
      return nil unless movement && single_movement_distance_makes_sense?(movement)

      build_workout(movement)
    end

    private

    attr_reader :row

    # Same exclusion as MaxRepDetector, and for the same reason: monostructural movements are
    # scored in calories/distance-within-a-time-cap via MonostructuralDetector, not a bare
    # achieved value; "rest" isn't a real exercise.
    def single_movement_distance_makes_sense?(movement)
      !movement.family_monostructural? && !movement.family_rest?
    end

    def build_workout(movement)
      workout = Workout.new(score_type: :distance, name: "Max #{movement.name} Height")
      segment = workout.segments.build(position: 1)
      segment.exercises.build(movement: movement, position: 1)
      workout
    end
  end
end
