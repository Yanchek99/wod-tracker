class Exercise < ApplicationRecord
  include ExercisePositionValidation

  belongs_to :workout
  belongs_to :movement
  belongs_to :segment, optional: true
  has_many :metrics, as: :measurable, dependent: :destroy

  default_scope { order(:position).includes(:metrics) }

  accepts_nested_attributes_for :metrics, allow_destroy: true

  validates :distance_units_per_rep,
            numericality: { only_integer: true, greater_than: 0 },
            allow_nil: true
  validate :distance_units_per_rep_matches_prescribed_distance

  def score_component
    return distance_score_component if distance_units_per_rep.present?

    calorie = metric_for(:calorie)
    return score_component_for(calorie) if scorable_metric?(calorie)

    rep = metric_for(:rep)
    return score_component_for(rep) if scorable_metric?(rep)

    nil
  end

  def load_bearing?
    metrics.any? { |metric| Metric::LOAD_MEASUREMENTS.include?(metric.measurement) }
  end

  private

  def distance_score_component
    distance = distance_metric
    return nil unless scorable_metric?(distance) && distance_units_per_rep.positive?

    score_reps = distance.value / distance_units_per_rep
    {
      measurement: distance.measurement,
      prescribed_value: distance.value,
      score_reps: score_reps,
      distance_units_per_rep: distance_units_per_rep
    }
  end

  def score_component_for(metric)
    {
      measurement: metric.measurement,
      prescribed_value: metric.value,
      score_reps: metric.value
    }
  end

  def metric_for(measurement)
    metrics.find { |metric| metric.measurement == measurement.to_s }
  end

  def distance_metric
    metrics.find { |metric| Metric::DISTANCE_MEASUREMENTS.include?(metric.measurement) }
  end

  def scorable_metric?(metric)
    metric&.value.present? && metric.value.positive?
  end

  def distance_units_per_rep_matches_prescribed_distance
    return if distance_units_per_rep.blank?

    distance = distance_metric
    if distance.blank?
      errors.add(:distance_units_per_rep, 'requires a distance metric')
    elsif distance.value.blank? || !distance.value.positive?
      errors.add(:distance_units_per_rep, 'requires a positive distance value')
    elsif (distance.value % distance_units_per_rep).nonzero?
      errors.add(:distance_units_per_rep, 'must divide the prescribed distance evenly')
    end
  end
end
