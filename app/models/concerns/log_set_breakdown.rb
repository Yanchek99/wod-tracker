module LogSetBreakdown
  extend ActiveSupport::Concern

  included do
    before_validation :resync_trivial_set_breakdown
  end

  # The sequence of round sizes to chunk a movement log's flat set_breakdown array against for
  # display -- [] when no round structure is knowable for this movement (e.g. a single-lift day,
  # or a movement with no round structure at all like Murph's pull-ups), in which case the whole
  # set_breakdown stays one ungrouped round.
  def round_sizes_for_set_breakdown(movement_log)
    index = movement_logs.index(movement_log)
    return [] unless index

    exercise = workout.exercises_for_log_recording[index]
    return [] unless exercise
    return exercise.segment.interval_scheme.split('-').map(&:to_i) if exercise.reps_defined_by_interval?
    return ladder_round_sizes_for(exercise) if exercise.ladder_participant?

    amrap_round_sizes_for(index)
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
