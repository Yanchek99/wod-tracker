module LogFixedRoundsSizing
  extend ActiveSupport::Concern

  included do
    before_validation :assign_fixed_rounds_set_breakdown_targets
  end

  private

  # For a movement repeated every round of a fixed "N rounds" segment (Segment#rounds? -- a plain
  # round count, no time cap, no interval scheme, e.g. Barbara's "5 rounds: 20 pull-ups, 30
  # push-ups, 40 sit-ups, 50 squats"), MovementLog#reps holds the *per-round* prescribed count (see
  # the "records per-round prescribed reps for segment exercises" behavior), not the lifetime total
  # across all rounds -- so a set_breakdown covering the whole effort (one comma-separated entry
  # per round, per the recording form's own hint) can never sum to reps directly. This gives each
  # such movement's log a target of reps * rounds to validate set_breakdown against instead.
  #
  # Skips reps <= 1 (a single logged rep, or the reps: 0 max-effort sentinel) -- those are either
  # already-unbroken efforts or a placeholder for a non-rep dimension (e.g. reps: 1 alongside a
  # real distance value, as in a run repeated every round), never a genuine per-round count meant
  # to be multiplied out. Also skips ladder participants (LogAscendingLadderSizing already computes
  # their growing target) and set-based lifting (already exploded into one MovementLog row per
  # round by WorkoutScoring#exercises_for_log_recording, so its reps is already the true total).
  def assign_fixed_rounds_set_breakdown_targets
    return if workout.set_based_lifting?

    workout.exercises_for_log_recording.each_with_index do |exercise, index|
      next unless fixed_rounds_multipliable?(exercise)

      movement_log = movement_logs[index]
      next if movement_log&.set_breakdown.blank?

      movement_log.set_breakdown_target_reps = exercise.reps * exercise.segment.rounds
    end
  end

  def fixed_rounds_multipliable?(exercise)
    exercise&.segment&.rounds? && exercise.reps.to_i > 1 && !exercise.ladder_participant?
  end
end
