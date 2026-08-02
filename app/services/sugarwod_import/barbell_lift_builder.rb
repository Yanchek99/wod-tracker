class SugarwodImport
  class BarbellLiftBuilder
    def self.call(row) = new(row).build

    def initialize(row)
      @row = row
    end

    def build
      return nil if row[:barbell_lift].blank?

      movement = CfWod::MovementLookup.call(row[:barbell_lift])
      return nil unless movement

      sets = SetSchemeExtractor.call(row)
      return nil unless sets

      build_workout(movement, sets)
    end

    private

    attr_reader :row

    def build_workout(movement, sets)
      name = "#{movement.name} #{sets.pluck(:reps).join('-')}"
      workout = Workout.new(score_type: :weight, name: name)
      segment = workout.segments.build(position: 1)
      sets.each_with_index do |set, index|
        segment.exercises.build(movement: movement, position: index + 1, reps: set[:reps])
      end
      workout
    end
  end
end
