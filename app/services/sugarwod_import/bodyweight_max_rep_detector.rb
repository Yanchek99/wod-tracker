class SugarwodImport
  class BodyweightMaxRepDetector
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
      return nil unless movement&.family_gymnastics?

      build_workout(movement)
    end

    private

    attr_reader :row

    def build_workout(movement)
      workout = Workout.new(score_type: :rep, name: "Max #{movement.name}")
      segment = workout.segments.build(position: 1)
      segment.exercises.build(movement: movement, position: 1, reps: 0)
      workout
    end
  end
end
