module StimulusLearner
  # Grouping keys the field learners match examples on. They read only the prescription, so a
  # labeled example and an unlabeled target compare like for like.
  module Structure
    module_function

    # A workout's shape: score type, segment kind, whether it has rest segments, whether any
    # movement carries a load, and whether its sets are low-rep (1-5) or higher.
    def workout_key(workout)
      exercises = workout.segments.flat_map(&:exercises)
      [
        workout.score_type,
        segment_kind(workout.governing_segment || workout.segments.first),
        exercises.any? { |exercise| exercise.movement.family_rest? },
        exercises.any? { |exercise| loaded?(exercise) },
        exercises.filter_map { |exercise| reps_per_set(exercise) }.max.to_i.between?(1, 5)
      ]
    end

    # A prescribed load, including a find-a-max's empty (zero) load.
    def loaded?(exercise)
      exercise.load_bearing? || !exercise.load.nil?
    end

    # A movement plus how many reps a single set asks for.
    def exercise_key(exercise)
      [exercise.movement_id, reps_bucket(reps_per_set(exercise))]
    end

    # Checked in order: an EMOM is also timed rounds, so it must win first.
    SEGMENT_KINDS = { emom: :emom?, amrap: :amrap?, interval: :interval?, rounds: :rounds?, timed_rounds: :timed_rounds? }.freeze

    def segment_kind(segment)
      return :none unless segment

      kind = SEGMENT_KINDS.find { |_, predicate| segment.public_send(predicate) }&.first
      kind == :timed_rounds ? :rounds : kind || :single
    end

    # Reps in one set: the interval scheme's first step (Fran's 21) or the exercise's own reps.
    def reps_per_set(exercise)
      scheme = exercise.segment.interval_scheme
      return scheme.split('-').first.to_i * (exercise.reps || 1) if scheme.present?

      exercise.reps
    end

    def reps_bucket(reps)
      return :none if reps.to_i.zero?
      return :low if reps <= 5

      reps <= 20 ? :mid : :high
    end
  end
end
