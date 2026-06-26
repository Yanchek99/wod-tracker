class Exercise < ApplicationRecord
  include ExercisePositionValidation
  include ExercisePrescription
  include RefreshesWorkoutContentKey

  SEX_PAIRED_DIMENSIONS = %i[load distance calories].freeze

  belongs_to :workout
  belongs_to :movement
  belongs_to :segment, optional: true

  default_scope { order(:position) }

  validates :reps, :calories,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :duration_seconds, :load, :female_load, :male_load,
            :distance, :female_distance, :male_distance, :female_calories, :male_calories,
            numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :distance_units_per_rep,
            numericality: { only_integer: true, greater_than: 0 },
            allow_nil: true
  validates :implement_count,
            numericality: { only_integer: true, greater_than: 0 },
            allow_nil: true
  validates :ladder_step_every,
            numericality: { only_integer: true, greater_than: 0 },
            allow_nil: true
  validate :prescription_values_are_unambiguous
  validate :distance_units_per_rep_matches_prescribed_distance
  validate :implement_count_requires_load

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

  # Rides the workout's ascending ladder. Every exercise in a ladder workout participates unless it
  # is flagged constant (ladder_exempt), e.g. a fixed walking lunge or shuttle run.
  def ladder_participant?
    workout&.ascending_ladder? && !ladder_exempt
  end

  # Reps performed in the given 1-indexed round when riding the ladder. The exercise's own reps are
  # the round-1 start; ladder_step_every is the number of rounds between increments (1 = grow every
  # round; 3 = hold for three rounds, as in 15.4).
  def ladder_reps(round)
    return unless ladder_participant? && reps

    every = ladder_step_every.to_i
    every = 1 if every < 1
    rung = (round - 1) / every
    reps + (rung * workout.ladder_step)
  end

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

  def implement_count_requires_load
    return if implement_count.to_i <= 1 # a single implement is the default and needs no load

    errors.add(:implement_count, 'requires a load') unless load_bearing?
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
