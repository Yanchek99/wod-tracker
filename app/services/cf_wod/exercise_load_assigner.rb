module CfWod
  module ExerciseLoadAssigner
    def self.assign(exercise, result)
      if result.dimension == :load
        exercise.assign_attributes(female_load: result.female_value, male_load: result.male_value, load_unit: result.unit)
      else
        exercise.assign_attributes(female_distance: result.female_value, male_distance: result.male_value, distance_unit: result.unit)
      end
    end
  end
end
