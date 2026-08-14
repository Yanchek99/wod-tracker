module LogAmrapRoundSizing
  extend ActiveSupport::Concern

  included do
    before_validation :assign_amrap_set_breakdown_targets
  end

  private

  # For an AMRAP-repeated movement (a couplet/triplet where the same movement recurs every
  # round), MovementLog#reps holds the *per-round* count, not a lifetime total -- so a
  # set_breakdown covering the whole effort (e.g. many rounds' worth of reps for one movement)
  # can never sum to reps directly. This computes each such movement's true total across all
  # rounds -- full rounds at its per-round rate, plus its share of a partial final round,
  # attributed in round order (movements earlier in the round get full credit for the partial
  # round before movements later in the round get any) -- and gives MovementLog a target to
  # validate set_breakdown against instead. Bails out entirely (leaving every movement's target
  # at its own default) if any component's per-round value can't be determined -- e.g. a
  # distance-based leg -- rather than risk misattributing the partial-round budget to the wrong
  # movement.
  def assign_amrap_set_breakdown_targets
    return unless rep_scored_amrap_log?

    parts = amrap_score_parts
    return unless parts

    per_round_values = amrap_component_per_round_values
    return if per_round_values.blank?

    shares = amrap_partial_shares(per_round_values, parts[:reps])
    movement_logs.each_with_index do |movement_log, index|
      next if movement_log.set_breakdown.blank?

      movement_log.set_breakdown_target_reps = (parts[:rounds] * per_round_values[index]) + shares[index]
    end
  end

  # The share of a partial final round each position gets, walked in round order: positions
  # earlier in the round consume the partial-round budget first, positions later in the round
  # (or never reached) get zero. Returns one share value per position, same order as
  # per_round_values.
  def amrap_partial_shares(per_round_values, total_partial)
    remaining = total_partial
    per_round_values.map do |per_round|
      share = [remaining, per_round].min
      remaining -= share
      share
    end
  end

  # The sequence of round sizes for the movement at this position -- e.g. [5, 5, 5, ..., 5, 3]
  # for 20 full rounds of 5 plus a partial round where this position only got 3 reps in before
  # time ran out. Used to reconstruct round groupings for display from the flat set_breakdown
  # array; returns [] when nothing about this AMRAP is fully known yet.
  def amrap_round_sizes_for(index)
    return [] unless rep_scored_amrap_log?

    parts = amrap_score_parts
    return [] unless parts

    per_round_values = amrap_component_per_round_values
    return [] if per_round_values.blank?

    per_round = per_round_values[index]
    return [] unless per_round

    sizes = [per_round] * parts[:rounds]
    share = amrap_partial_shares(per_round_values, parts[:reps])[index]
    sizes << share if share.positive?
    sizes
  end

  # The per-round rep value for each movement in round order, or nil if any component's
  # value can't be determined (e.g. a distance-based leg) -- the caller bails out entirely in
  # that case rather than risk misattributing the partial-round budget to the wrong movement.
  def amrap_component_per_round_values
    components = workout.amrap_score_components
    return nil if components.blank? || components.size != movement_logs.size

    per_round_values = components.map.with_index { |component, index| submitted_score_reps_for(component, movement_logs[index]) }
    return nil if per_round_values.any? { |value| value.blank? || value.zero? }

    per_round_values
  end

  def submitted_score_reps_for(component, movement_log)
    metric = movement_log.prescription_metrics.find { |m| m.measurement == component[:measurement] }
    return nil unless metric&.value.present? && metric.value.positive?
    return submitted_distance_score_reps(metric, component[:distance_units_per_rep]) if component[:distance_units_per_rep]

    metric.value
  end

  def submitted_distance_score_reps(metric, distance_units_per_rep)
    return nil if (metric.value % distance_units_per_rep).nonzero?

    metric.value / distance_units_per_rep
  end
end
