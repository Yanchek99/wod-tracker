module CfWod
  class ExerciseLoadAttacher
    INLINE_LOAD_CLAUSE = /\(([^)]*\d[^)]*)\)/

    def self.extract_inline(line)
      match = INLINE_LOAD_CLAUSE.match(line)
      return [line, nil] unless match

      result = ScaledLoadParser.parse(match[0])
      return [line, nil] unless result

      [line.sub(match[0], '').strip, result]
    end

    def self.apply(exercise, result)
      if result.dimension == :load
        exercise.assign_attributes(female_load: result.female_value, male_load: result.male_value, load_unit: result.unit)
      else
        exercise.assign_attributes(female_distance: result.female_value, male_distance: result.male_value, distance_unit: result.unit)
      end
    end
  end
end
