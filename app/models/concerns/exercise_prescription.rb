module ExercisePrescription
  extend ActiveSupport::Concern

  # Columns that indicate an exercise carries its prescription directly (not via legacy metrics).
  DIRECT_PRESCRIPTION_COLUMNS = %i[
    reps duration_seconds
    load female_load male_load load_unit
    distance female_distance male_distance distance_unit
    calories female_calories male_calories
  ].freeze

  included do
    enum :load_unit, { lb: 0, kg: 1 }, prefix: :load_unit
    enum :distance_unit, { meter: 0, foot: 1, inch: 2 }, prefix: :distance_unit
  end

  # Canonical prescription, preferring the direct columns and falling back to legacy metric rows
  # while both exist (legacy metrics are removed in a later phase). Rendering, scoring, and log
  # recording all read this, so column-backed and metric-backed exercises behave identically.
  # Memoized so the helper's object-identity comparisons see the same column-built instances.
  def prescription_metrics
    @prescription_metrics ||= build_prescription_metrics
  end

  def uses_direct_prescriptions?
    DIRECT_PRESCRIPTION_COLUMNS.any? { |column| self[column].present? }
  end

  private

  def build_prescription_metrics
    return metrics.to_a unless uses_direct_prescriptions?

    [
      rep_prescription_metric,
      duration_prescription_metric,
      load_prescription_metric,
      distance_prescription_metric,
      calorie_prescription_metric
    ].compact
  end

  def rep_prescription_metric
    return if reps.nil?

    Metric.new(measurement: :rep, value: reps.zero? ? nil : reps) # 0 is the "max reps" sentinel
  end

  def duration_prescription_metric
    return if duration_seconds.blank?

    Metric.new(measurement: :seconds, value: duration_seconds)
  end

  def load_prescription_metric
    return unless load_unit.present? || load.present? || female_load.present? || male_load.present?

    Metric.new(measurement: load_unit || :lb, value: load, female_value: female_load, male_value: male_load)
  end

  def distance_prescription_metric
    return unless distance_unit.present? || distance.present? || female_distance.present? || male_distance.present?

    Metric.new(measurement: distance_unit || :distance, value: distance,
               female_value: female_distance, male_value: male_distance)
  end

  def calorie_prescription_metric
    return unless calories.present? || female_calories.present? || male_calories.present?

    Metric.new(measurement: :calorie, value: (calories&.zero? ? nil : calories), # 0 is "max calories"
               female_value: female_calories, male_value: male_calories)
  end
end
