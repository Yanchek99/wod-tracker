# Builds labeled training examples for the stimulus learner: workouts whose stimulus columns
# were "extracted" from CrossFit's prose, so StimulusLearner::Examples picks them up.
module StimulusExamples
  SEGMENT_KEYS = %i[rounds interval_scheme time_seconds].freeze

  private

  # options: score_type (default :time), segment keys (rounds, interval_scheme, time_seconds),
  # movements (hashes of exercise attributes; any stimulus_* keys label that exercise), and any
  # workout stimulus_* columns.
  def labeled_workout(name, movements: [], **options)
    workout = Workout.create!(name:, score_type: options.delete(:score_type) || :time, stimulus_source: :extracted,
                              **options.except(*SEGMENT_KEYS))
    segment = workout.segments.create!(position: 1, **options.slice(*SEGMENT_KEYS))
    movements.each.with_index(1) do |attrs, position|
      stimulus = attrs.select { |key, _| key.to_s.start_with?('stimulus_') }
      source = stimulus.any? ? { stimulus_source: :extracted } : {}
      segment.exercises.create!(position:, **attrs, **source)
    end
    workout
  end

  # An unlabeled workout the learner should predict for.
  def target_workout(name, movements: [], **options)
    workout = Workout.create!(name:, score_type: options.delete(:score_type) || :time)
    segment = workout.segments.create!(position: 1, **options.slice(*SEGMENT_KEYS))
    movements.each.with_index(1) { |attrs, position| segment.exercises.create!(position:, **attrs) }
    workout.reload
  end
end
