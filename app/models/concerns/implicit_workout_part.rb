module ImplicitWorkoutPart
  extend ActiveSupport::Concern

  # Backfilled wrappers preserve the old workout-part shape: the workout owns the
  # scheme/objective, and this segment only groups the exercises that used to be top-level.
  def implicit_workout_part?
    blank_wrapper? && workout.present? && segment_scheme == workout_part_scheme
  end

  private

  def blank_wrapper?
    name.blank? && rest_seconds.blank? && notes.blank?
  end

  def segment_scheme
    {
      rounds: rounds,
      time_seconds: time_seconds,
      interval_scheme: interval_scheme.presence
    }.compact
  end

  def workout_part_scheme
    return {} if unschemed_weight_workout?
    return nil if unschemed_workout?

    workout_real_scheme
  end

  def unschemed_weight_workout?
    workout.score_measurement == 'weight' && unschemed_workout?
  end

  def unschemed_workout?
    workout.rounds.to_i <= 1 && workout.time.blank? && workout.interval.blank?
  end

  def workout_real_scheme
    {
      rounds: workout_rounds,
      time_seconds: workout_time_seconds,
      interval_scheme: workout.interval.presence
    }.compact
  end

  def workout_rounds
    workout.rounds if workout.rounds.to_i > 1
  end

  def workout_time_seconds
    workout.time * 60 if workout.time.present?
  end
end
