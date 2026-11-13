module StimulusCalculator
  # Prescribed work for one exercise, keyed by the reference table's pace units: rep, meter,
  # calorie, second (other distance units keep their own key and so have no pace). Empty means
  # the volume is unknown.
  #
  # Reps count only for a rep-measured movement: the scraper stores a reps: 1 placeholder on
  # distance and calorie lines, so a distance, calorie or duration measure wins. An interval
  # scheme such as 21-15-9 supplies the reps -- and the calories or meters of a value-1
  # placeholder ("21-15-9 calorie row" is stored as calories: 1). Sex-split distance and
  # calories use the male side.
  module Volume
    MEASURES = { calorie: %i[calories male_calories], second: %i[duration_seconds] }.freeze

    module_function

    # Across all of the segment's rounds.
    def for(exercise)
      segment = exercise.segment
      measured = measures(exercise)
      return { rep: reps_total(exercise) }.select { |_, value| value.positive? } if measured.empty?

      measured.transform_values { |value| total(value, segment) }
    end

    # One effort: the first set of an interval scheme, or one round.
    def per_effort(exercise)
      measured = measures(exercise)
      return { rep: reps_per_set(exercise) }.select { |_, value| value.positive? } if measured.empty?

      scheme = exercise.segment.interval_scheme
      first_step = scheme.present? ? scheme.split('-').first.to_i : 1
      measured.transform_values { |value| value == 1 && scheme.present? ? first_step : value }
    end

    def reps_per_set(exercise)
      scheme = exercise.segment.interval_scheme
      return scheme.split('-').first.to_i * (exercise.reps || 1) if scheme.present?

      exercise.reps.to_i
    end

    def reps_total(exercise)
      segment = exercise.segment
      return segment.reps_from_interval * (exercise.reps || 1) if segment.interval?

      exercise.reps.to_i * (segment.rounds || 1)
    end

    # Distance, calories and duration per round (or per scheme step), positive only.
    def measures(exercise)
      distance = exercise.distance || exercise.male_distance
      found = { "#{exercise.distance_unit || 'meter'}": distance.to_i }
      MEASURES.each { |unit, columns| found[unit] = columns.filter_map { |column| exercise[column] }.first.to_i }
      found.select { |_, value| value.positive? }
    end

    def total(value, segment)
      return value * (segment.rounds || 1) unless segment.interval?

      value == 1 ? segment.reps_from_interval : value * segment.interval_scheme.split('-').size
    end
  end
end
