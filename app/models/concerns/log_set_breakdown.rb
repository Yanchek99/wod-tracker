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
    return [exercise.reps] * exercise.segment.rounds if fixed_rounds_multipliable?(exercise)

    amrap_round_sizes_for(index)
  end

  private

  # A single logged rep, or a set within a dedicated set-based lifting workout (see
  # Workout#set_based_lifting? -- a fixed "5x5 Back Squat", or a variable build like "Back Squat:
  # 5-5-3-3-1-1"), is unbroken by construction -- no self-report needed. reps: 0 is this app's
  # existing "unspecified/max effort" sentinel (see ExercisePrescription#rep_prescription_metric),
  # not a literal single rep, so it's excluded here and left unpopulated like any other
  # not-yet-known case. Excludes structured round-repeat movements (AMRAPs, ascending ladders)
  # entirely: for these, reps is a per-round value, not a lifetime total, so a build-time reps == 1
  # says nothing about what the eventual set_breakdown target will be once score_value is known.
  def auto_populate_set_breakdown(movement_log, exercise)
    return if movement_log.reps.blank? || movement_log.reps.zero?
    return if structured_round_repeat?(exercise)
    return unless movement_log.reps == 1 || single_weightlifting_exercise_day?(exercise)

    movement_log.set_breakdown = [movement_log.reps]
  end

  def single_weightlifting_exercise_day?(exercise)
    exercise.movement.family_weightlifting? &&
      workout.set_based_lifting? &&
      !exercise.reps_defined_by_interval?
  end

  # True when this exercise's reps is a per-round value rather than a lifetime total -- an
  # AMRAP-repeated movement, or a movement riding an ascending ladder. set_breakdown auto-fill
  # and resync must never touch these; only assign_amrap_set_breakdown_targets /
  # assign_ascending_ladder_set_breakdown_targets know the real (score-dependent) target.
  def structured_round_repeat?(exercise)
    workout.rep_scored_amrap? || exercise.ladder_participant?
  end

  def resync_trivial_set_breakdown
    exercises = workout.exercises_for_log_recording
    movement_logs.each_with_index do |movement_log, index|
      exercise = exercises[index]
      next unless resyncable_set_breakdown?(movement_log, exercise)

      movement_log.set_breakdown = [movement_log.reps]
    end
  end

  # Skips resync entirely once the athlete has actually typed something into the (visible)
  # set_breakdown_text field this request -- that's a deliberate self-report, even if it turns
  # out to mismatch reps, and must be left alone for normal validation to accept or reject
  # rather than silently overwritten. Otherwise, falls back to the original single-or-blank-value
  # heuristic, which still covers direct reps edits that never touch set_breakdown_text at all
  # (e.g. a hidden field submitting blank, or reps set programmatically).
  def resyncable_set_breakdown?(movement_log, exercise)
    return false unless exercise
    return false if structured_round_repeat?(exercise)
    return false if movement_log.set_breakdown_text_submitted?

    single_weightlifting_exercise_day?(exercise) &&
      movement_log.reps.present? && movement_log.reps.positive? &&
      movement_log.set_breakdown.compact.size <= 1
  end
end
