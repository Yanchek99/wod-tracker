module LogScoring
  extend ActiveSupport::Concern

  RAW_AMRAP_REPS_PATTERN = /\A\s*\d+\s*\z/
  ROUNDS_PLUS_REPS_PATTERN = /\A\s*(\d+)\s*\+\s*(\d+)\s*\z/

  included do
    before_validation :calculate_set_based_lifting_score
    before_validation :convert_fixed_amrap_round_score_to_reps
    before_validation :normalize_amrap_score
    before_validation :assign_amrap_set_breakdown_targets
  end

  def amrap_score_parts
    return nil unless rep_scored_amrap_log?
    return nil unless score_value.present? && reps_per_round.present? && reps_per_round.positive?

    rounds, reps = score_value.divmod(reps_per_round)
    { rounds: rounds, reps: reps, total: score_value }
  end

  private

  def normalize_amrap_score
    return unless rep_scored_amrap_log?

    round_total = submitted_amrap_reps_per_round || workout.amrap_reps_per_round
    normalized_value = normalize_amrap_score_value(score_value_before_type_cast, round_total)

    return if errors[:base].any? || errors[:score_value].any?

    self.score_value = normalized_value
    self.reps_per_round = round_total if round_total.present?
  end

  def calculate_set_based_lifting_score
    return unless workout&.calculated_lifting_score? && score_measurement == 'weight'

    score = workout.lifting_score(movement_logs)
    return unless score

    self.score_type = score.measurement
    self.score_value = score.value
  end

  def convert_fixed_amrap_round_score_to_reps
    return unless workout&.fixed_rep_amrap? && score_measurement == 'round'

    self.score_type = :rep
  end

  def normalize_amrap_score_value(raw_value, round_total)
    case raw_value
    when Integer
      raw_value.negative? ? invalid_amrap_score_value : raw_value
    when RAW_AMRAP_REPS_PATTERN
      raw_value.to_i
    when ROUNDS_PLUS_REPS_PATTERN
      normalize_rounds_plus_reps(Regexp.last_match(1).to_i, Regexp.last_match(2).to_i, round_total)
    else
      invalid_amrap_score_value
    end
  end

  def normalize_rounds_plus_reps(rounds, reps, round_total)
    if round_total.blank?
      errors.add(:score_value, 'rounds plus reps requires a fixed reps-per-round total')
      return score_value
    end

    (rounds * round_total) + reps
  end

  def invalid_amrap_score_value
    errors.add(:score_value, 'score must be total reps or rounds plus reps')
    score_value
  end

  def rep_scored_amrap_log?
    workout&.rep_scored_amrap? && score_measurement == 'rep'
  end

  def submitted_amrap_reps_per_round
    return nil if movement_logs.blank?

    amrap_component_per_round_values&.sum
  end

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
    return unless rep_scored_amrap_log? && !fixed_rung_ladder?

    parts = amrap_score_parts
    return unless parts

    per_round_values = amrap_component_per_round_values
    return if per_round_values.blank?

    movement_logs.each_with_index.reduce(parts[:reps]) do |remaining_partial, (movement_log, index)|
      assign_set_breakdown_target(movement_log, per_round_values[index], parts[:rounds], remaining_partial)
    end
  end

  def assign_set_breakdown_target(movement_log, per_round, rounds, remaining_partial)
    partial_share = [remaining_partial, per_round].min
    movement_log.set_breakdown_target_reps = (rounds * per_round) + partial_share if movement_log.set_breakdown.present?

    remaining_partial - partial_share
  end

  # e.g. Open 14.3: a movement repeats across rungs at varying reps, not identically every round.
  def fixed_rung_ladder?
    movement_logs.map(&:movement_id).uniq.size != movement_logs.size
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
