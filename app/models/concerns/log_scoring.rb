module LogScoring
  extend ActiveSupport::Concern

  RAW_AMRAP_REPS_PATTERN = /\A\s*\d+\s*\z/
  ROUNDS_PLUS_REPS_PATTERN = /\A\s*(\d+)\s*\+\s*(\d+)\s*\z/

  included do
    before_validation :calculate_set_based_lifting_score
    before_validation :convert_fixed_amrap_round_score_to_reps
    before_validation :normalize_amrap_score
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

    return if errors[:base].any? || errors[:metric].any?

    self.score_value = normalized_value
    self.reps_per_round = round_total if round_total.present?
  end

  def calculate_set_based_lifting_score
    return unless workout&.set_based_lifting? && score_type == 'weight'

    score = workout.lifting_score(movement_logs)
    return unless score

    self.score_type = score.measurement
    self.score_value = score.value
  end

  def convert_fixed_amrap_round_score_to_reps
    return unless workout&.fixed_rep_amrap? && score_type == 'round'

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
      errors.add(:metric, 'rounds plus reps requires a fixed reps-per-round total')
      return score_value
    end

    (rounds * round_total) + reps
  end

  def invalid_amrap_score_value
    errors.add(:metric, 'score must be total reps or rounds plus reps')
    score_value
  end

  def rep_scored_amrap_log?
    workout&.rep_scored_amrap? && score_type == 'rep'
  end

  def submitted_amrap_reps_per_round
    return nil if movement_logs.blank?

    components = workout.amrap_score_components
    return nil if components.blank? || components.size != movement_logs.size

    score_reps = components.map.with_index do |component, index|
      submitted_score_reps_for(component, movement_logs[index])
    end
    return nil if score_reps.any?(&:nil?)

    score_reps.sum
  end

  def submitted_score_reps_for(component, movement_log)
    metric = movement_log.metrics.find { |m| m.measurement == component[:measurement] }
    return nil unless metric&.value.present? && metric.value.positive?
    return submitted_distance_score_reps(metric, component[:distance_units_per_rep]) if component[:distance_units_per_rep]

    metric.value
  end

  def submitted_distance_score_reps(metric, distance_units_per_rep)
    return nil if (metric.value % distance_units_per_rep).nonzero?

    metric.value / distance_units_per_rep
  end
end
