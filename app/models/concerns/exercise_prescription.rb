module ExercisePrescription
  extend ActiveSupport::Concern

  included do
    enum :load_unit, { lb: 0, kg: 1 }, prefix: :load_unit
    enum :distance_unit, { meter: 0, foot: 1, inch: 2 }, prefix: :distance_unit
  end

  # Canonical prescription, built from the exercise's columns as in-memory Metric value objects.
  # Rendering, scoring, and log recording all read this. Memoized so the helper's object-identity
  # comparisons see the same column-built instances.
  def prescription_metrics
    @prescription_metrics ||= [
      rep_prescription_metric,
      duration_prescription_metric,
      load_prescription_metric,
      distance_prescription_metric,
      calorie_prescription_metric
    ].compact
  end

  def max_load_prescription?
    reps.to_i.positive? &&
      duration_seconds.present? &&
      load_unit.present? &&
      load.blank? &&
      female_load.blank? &&
      male_load.blank?
  end

  def max_load_test?
    max_load_prescription? && workout&.max_finding?
  end

  private

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

    Metric.new(measurement: load_unit || :lb, value: load, female_value: female_load, male_value: male_load,
               implement_count: implement_count)
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
