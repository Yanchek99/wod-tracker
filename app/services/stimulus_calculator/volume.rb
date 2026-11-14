module StimulusCalculator
  # Prescribed work for one exercise, keyed by the reference table's pace units: rep, meter,
  # calorie, second (other distance units keep their own key and so have no pace). Empty means
  # the volume is unknown.
  #
  # The scraper stores a reps: 1 placeholder on distance and calorie lines, so with one rep (or
  # none) a distance, calorie or duration measure wins; with real reps the reps are the work. An interval
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

      first_step = first_scheme_step(exercise.segment)
      measured.transform_values { |value| value == 1 && first_step ? first_step : value }
    end

    # The first step of an interval scheme (21 for 21-15-9); nil without a scheme.
    def first_scheme_step(segment)
      segment.interval_scheme.split('-').first.to_i if segment.interval?
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

    # Distance, calories and duration per round (or per scheme step), positive only. Real reps
    # (more than one) are the work themselves: a distance beside them is a height or target
    # (wall-ball 10 ft, box 24 in, rope 15 ft), not distance travelled.
    def measures(exercise)
      return {} if exercise.reps.to_i > 1

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
