module ExercisePrescription
  extend ActiveSupport::Concern

  included do
    enum :distance_unit, { meter: 0, foot: 1, inch: 2 }, prefix: :distance_unit

    before_validation :canonicalize_load_input
    before_validation :derive_load_bearing
  end

  # Transient input unit (lb/kg/pood) for a load being written from a form, import, or seed. Loads
  # are stored canonically in pounds (see cf/docs/load-and-distance-equivalence.md), so this is
  # normalized away on save and never persisted; assigning it also marks the prescription
  # load-bearing, which is how a find-a-max (a load with no fixed value) is expressed.
  def load_unit = @load_unit

  def load_unit=(unit)
    @load_unit = unit
    self.load_bearing = true if unit.present? # a supplied unit means the prescription bears a load
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
      load_bearing? &&
      load.blank? &&
      female_load.blank? &&
      male_load.blank?
  end

  def max_load_test?
    max_load_prescription? && workout&.max_finding?
  end

  private

  # Normalizes any lb/kg/pood load input to the canonical pounds magnitude and marks the
  # prescription load-bearing. A pounds (or blank) unit needs no conversion.
  def canonicalize_load_input
    return if @load_unit.blank?

    self.load_bearing = true
    unit = @load_unit.to_s
    unless unit == 'lb'
      %i[load female_load male_load].each do |attribute|
        value = self[attribute]
        self[attribute] = LoadEquivalence.to_lb(value, unit) if value.present?
      end
    end
    @load_unit = 'lb' # normalized; re-running is a no-op
  end

  # A prescription with any load value is load-bearing even when no input unit was supplied.
  def derive_load_bearing
    self.load_bearing = true if load.present? || female_load.present? || male_load.present?
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
    return unless load_bearing? || load.present? || female_load.present? || male_load.present?

    Metric.new(measurement: :lb, value: load, female_value: female_load, male_value: male_load,
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
