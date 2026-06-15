class Exercise < ApplicationRecord
  include ExercisePositionValidation
  include ExercisePrescription

  SEX_PAIRED_DIMENSIONS = %i[load distance calories].freeze

  belongs_to :workout
  belongs_to :movement
  belongs_to :segment, optional: true
  has_many :metrics, as: :measurable, dependent: :destroy

  default_scope { order(:position).includes(:metrics) }

  accepts_nested_attributes_for :metrics, allow_destroy: true

  validates :reps, :calories,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :duration_seconds, :load, :female_load, :male_load,
            :distance, :female_distance, :male_distance, :female_calories, :male_calories,
            numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :distance_units_per_rep,
            numericality: { only_integer: true, greater_than: 0 },
            allow_nil: true
  validate :prescription_values_are_unambiguous
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
    prescription_metrics.any? { |metric| Metric::LOAD_MEASUREMENTS.include?(metric.measurement) }
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
    prescription_metrics.find { |metric| metric.measurement == measurement.to_s }
  end

  def distance_metric
    prescription_metrics.find { |metric| Metric::DISTANCE_MEASUREMENTS.include?(metric.measurement) }
  end

  def scorable_metric?(metric)
    metric&.value.present? && metric.value.positive?
  end

  def prescription_values_are_unambiguous
    SEX_PAIRED_DIMENSIONS.each do |dimension|
      value = self[dimension]
      female = self[:"female_#{dimension}"]
      male = self[:"male_#{dimension}"]

      if value.present? && (female.present? || male.present?)
        errors.add(dimension, 'cannot be set with sex-specific values')
      elsif female.blank? != male.blank?
        errors.add(:base, "#{dimension} requires both female and male values")
      end
    end
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
