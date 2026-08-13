module LogSetBreakdown
  extend ActiveSupport::Concern

  included do
    before_validation :resync_trivial_set_breakdown
  end

  private

  # A single logged rep, or a dedicated single-lift weightlifting day, is unbroken by
  # construction -- no self-report needed. reps: 0 is this app's existing "unspecified/max
  # effort" sentinel (see ExercisePrescription#rep_prescription_metric), not a literal single
  # rep, so it's excluded here and left unpopulated like any other not-yet-known case.
  def auto_populate_set_breakdown(movement_log, exercise)
    return if movement_log.reps.blank? || movement_log.reps.zero?
    return unless movement_log.reps == 1 || single_weightlifting_exercise_day?(exercise)

    movement_log.set_breakdown = [movement_log.reps]
  end

  def single_weightlifting_exercise_day?(exercise)
    exercise.movement.family_weightlifting? &&
      workout.exercises.one? &&
      !exercise.reps_defined_by_interval?
  end

  def resync_trivial_set_breakdown
    exercises = workout.exercises_for_log_recording
    movement_logs.each_with_index do |movement_log, index|
      exercise = exercises[index]
      next unless resyncable_set_breakdown?(movement_log, exercise)

      movement_log.set_breakdown = [movement_log.reps]
    end
  end

  def resyncable_set_breakdown?(movement_log, exercise)
    return false unless exercise

    single_weightlifting_exercise_day?(exercise) &&
      movement_log.reps.present? && movement_log.reps.positive? &&
      movement_log.set_breakdown.compact.size <= 1
  end
end
