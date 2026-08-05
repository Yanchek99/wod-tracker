class SugarwodImport
  class MonostructuralDetector
    TRAILING_NOTE = /\s*\*.*\z/m
    DISTANCE_METERS = /\A(?:for time:?\s*)?([\d,]+)\s*meter\s+(?:row|run|bike|ski)\z/i
    DISTANCE_M_ABBREV = /\A(?:for time:?\s*)?([\d,]+)[\s-]*m\s+(?:row|run|bike|ski)\z/i
    DISTANCE_K      = /\A(?:for time:?\s*)?(\d+)\s*k\s+(?:row|run|bike|ski)\z/i
    DISTANCE_MILES  = /\A(?:for time:?\s*)?(\d+(?:\.\d+)?)\s*miles?\s+(?:row|run|bike|ski)\z/i
    MOVEMENT_K      = /\A(?:for time:?\s*)?(?:row|run|bike|ski)\s+(\d+)\s*k\z/i
    MOVEMENT_MILES  = /\A(?:for time:?\s*)?(?:row|run|bike|ski)\s+(\d+(?:\.\d+)?)\s*miles?\z/i
    MAX_CALORIES    = /\A(\d+)\s*minute\s*max\s*calorie\s+(?:row|run|bike|ski)\z/i
    DISTANCE_STRATEGIES = [
      [DISTANCE_METERS, 'meter'],
      [DISTANCE_M_ABBREV, 'meter'],
      [DISTANCE_K, 'km'],
      [DISTANCE_MILES, 'mile'],
      [MOVEMENT_K, 'km'],
      [MOVEMENT_MILES, 'mile']
    ].freeze

    def self.call(row) = new(row).build

    def initialize(row)
      @row = row
    end

    def build
      return nil if row[:barbell_lift].present?

      description = normalized_description
      build_distance_for_time(description) || build_max_calories(description)
    end

    private

    attr_reader :row

    # The whole description must be the monostructural shape itself -- allowing only a
    # trailing "*Score = ..." annotation (present in real SugarWOD rows) -- so a multi-part
    # chipper that merely mentions a distance and a monostructural movement somewhere in its
    # text (e.g. a run/burpee/power-clean chipper) is not silently truncated into a bare
    # distance-for-time workout.
    def normalized_description
      row[:description].to_s.strip.sub(TRAILING_NOTE, '').strip
    end

    def build_distance_for_time(description)
      meters = extract_meters(description)
      return nil unless meters&.positive?

      movement = single_monostructural_movement(description)
      return nil unless movement

      build_workout(movement, score_type: :time, name: "#{movement.name} #{meters}m") do |exercise|
        exercise.distance = meters
        exercise.distance_unit = 'meter'
      end
    end

    def extract_meters(description)
      DISTANCE_STRATEGIES.each do |pattern, unit|
        value = description[pattern, 1]
        next unless value

        return DistanceEquivalence.to_meters(value.delete(',').to_f, unit)
      end
      nil
    end

    def build_max_calories(description)
      match = description.match(MAX_CALORIES)
      return nil unless match

      movement = single_monostructural_movement(description)
      return nil unless movement

      build_workout(movement, score_type: :calorie, name: "#{match[1]} Minute Max Calorie #{movement.name}") do |exercise|
        exercise.duration_seconds = match[1].to_i * 60
      end
    end

    def single_monostructural_movement(description)
      names = %w[row run bike ski].select { |name| description.match?(/\b#{name}\b/i) }
      return nil unless names.one?

      movement = CfWod::MovementLookup.call(names.first)
      movement if movement&.family_monostructural?
    end

    def build_workout(movement, score_type:, name:)
      workout = Workout.new(score_type: score_type, name: name)
      segment = workout.segments.build(position: 1)
      exercise = segment.exercises.build(movement: movement, position: 1)
      yield exercise
      workout
    end
  end
end
