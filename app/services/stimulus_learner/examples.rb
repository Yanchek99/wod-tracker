module StimulusLearner
  # The learner's training set: workouts and exercises whose stimulus columns hold CrossFit's
  # own published values (extracted from the Stimulus and Strategy prose) or a coach's authored
  # values. Never athlete logs -- a programmer writes the stimulus before anyone has logged it.
  class Examples
    LABEL_SOURCES = %i[extracted authored].freeze

    attr_reader :workouts, :exercises

    def self.load
      new(
        workouts: Workout.where(stimulus_source: LABEL_SOURCES)
                         .includes(segments: { exercises: :movement }).order(:id).to_a,
        exercises: Exercise.unscoped.where(stimulus_source: LABEL_SOURCES)
                           .includes(:movement, :segment).order(:id).to_a
      )
    end

    # Total prescribed work for one exercise across its segment's rounds: reps, distance (keyed
    # by unit, e.g. :distance_meter), calories, and seconds. An interval scheme such as Fran's
    # 21-15-9 supplies the reps (the exercise itself stores reps: 1).
    def self.volume(exercise)
      rounds = exercise.segment.rounds || 1
      {
        reps: reps(exercise, rounds),
        "distance_#{exercise.distance_unit || 'meter'}": exercise.distance.to_i * rounds,
        calories: exercise.calories.to_i * rounds,
        seconds: exercise.duration_seconds.to_i * rounds
      }.select { |_, value| value.positive? }
    end

    def self.reps(exercise, rounds)
      segment = exercise.segment
      return segment.reps_from_interval * (exercise.reps || 1) if segment.interval?

      exercise.reps.to_i * rounds
    end

    def initialize(workouts:, exercises:)
      @workouts = workouts
      @exercises = exercises
    end
  end
end
