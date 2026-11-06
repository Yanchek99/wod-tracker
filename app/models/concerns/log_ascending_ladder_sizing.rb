module LogAscendingLadderSizing
  extend ActiveSupport::Concern

  included do
    before_validation :assign_ascending_ladder_set_breakdown_targets
  end

  # The sequence of round sizes for this exercise's ladder participation, for display grouping
  # (see Log#round_sizes_for_set_breakdown) -- [] if this log isn't an interpretable ascending
  # ladder, or this exercise doesn't participate in it (see Exercise#ladder_participant?).
  def ladder_round_sizes_for(exercise)
    return [] unless ascending_ladder_log? && exercise.ladder_participant?

    participating = ladder_participant_exercises
    return [] if participating.blank?

    full_rounds, partial_reps = ladder_rounds_completed(participating)
    sizes = (1..full_rounds).map { |round| exercise.ladder_reps(round) }
    share = ladder_partial_shares(participating, full_rounds, partial_reps)[exercise.id]
    sizes << share if share&.positive?
    sizes
  end

  private

  # Walks rounds 1, 2, 3... summing every participating exercise's ladder_reps(round) together,
  # accumulating until the next round would exceed score_value. Returns [full_rounds,
  # partial_reps] -- rounds fully completed, and leftover reps into the next (incomplete) round.
  def assign_ascending_ladder_set_breakdown_targets
    return unless ascending_ladder_log?

    participating = ladder_participant_exercises
    return if participating.blank?

    full_rounds, partial_reps = ladder_rounds_completed(participating)
    shares = ladder_partial_shares(participating, full_rounds, partial_reps)

    workout.exercises_for_log_recording.each_with_index do |exercise, index|
      next unless exercise.ladder_participant?

      assign_ladder_target(exercise, movement_logs[index], full_rounds, shares)
    end
  end

  def assign_ladder_target(exercise, movement_log, full_rounds, shares)
    return if movement_log&.set_breakdown.blank?

    full_total = (1..full_rounds).sum { |round| exercise.ladder_reps(round) }
    movement_log.set_breakdown_target_reps = full_total + shares.fetch(exercise.id, 0)
  end

  def ascending_ladder_log?
    workout&.ascending_ladder? && score_measurement == 'rep' && score_value.present?
  end

  def ladder_participant_exercises
    workout.exercises_for_log_recording.select(&:ladder_participant?)
  end

  def ladder_rounds_completed(participating)
    cumulative = 0
    round = 1
    loop do
      round_total = participating.sum { |exercise| exercise.ladder_reps(round) }
      break if round_total.zero? || cumulative + round_total > score_value

      cumulative += round_total
      round += 1
    end
    [round - 1, score_value - cumulative]
  end

  # Same sequential-consumption idea as LogAmrapRoundSizing#amrap_partial_shares, but against
  # each exercise's round (full_rounds + 1) reps instead of a constant per-round value, since
  # ladder rounds grow. Keyed by exercise id (not the Exercise object itself) to avoid any doubt
  # about hash/equality across separately-queried instances of the same row.
  def ladder_partial_shares(participating, full_rounds, partial_reps)
    remaining = partial_reps
    participating.each_with_object({}) do |exercise, shares|
      per_round = exercise.ladder_reps(full_rounds + 1)
      share = [remaining, per_round].min
      remaining -= share
      shares[exercise.id] = share
    end
  end
end
