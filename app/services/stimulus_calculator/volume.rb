module StimulusCalculator
  # Prescribed work for one exercise, keyed by the reference table's pace units: rep, meter,
  # calorie, second (other distance units keep their own key and so have no pace). An interval
  # scheme such as Fran's 21-15-9 supplies the reps (the exercise itself stores reps: 1).
  # Sex-split distance and calories use the male side. Empty means the volume is unknown.
  module Volume
    module_function

    # Across all of the segment's rounds.
    def for(exercise)
      measure(exercise, reps_total(exercise), exercise.segment.rounds || 1)
    end

    # One effort: the first set of an interval scheme, or one round.
    def per_effort(exercise)
      measure(exercise, reps_per_set(exercise), 1)
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

    def measure(exercise, reps, rounds)
      {
        rep: reps,
        "#{exercise.distance_unit || 'meter'}": (exercise.distance || exercise.male_distance).to_i * rounds,
        calorie: (exercise.calories || exercise.male_calories).to_i * rounds,
        second: exercise.duration_seconds.to_i * rounds
      }.select { |_, value| value.positive? }
    end
  end
end
