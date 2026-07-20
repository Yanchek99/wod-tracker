module ExercisePrescription
  extend ActiveSupport::Concern

  SEX_PAIRED_DIMENSIONS = %i[load distance calories].freeze

  included do
    enum :distance_unit, { meter: 0, foot: 1, inch: 2 }, prefix: :distance_unit

    before_validation :canonicalize_load_input
  end

  # Transient input unit (lb/kg/pood) for a load being written from a form, import, or seed. Loads
  # are stored canonically in pounds (see cf/docs/load-and-distance-equivalence.md), so this is
  # normalized away on save and never persisted. A unit given with no fixed value marks a
  # find-a-max prescription, stored as load: 0 -- the same "unspecified" sentinel reps and calories
  # already use for their own max variants.
  attr_writer :load_unit

  def load_unit = @load_unit

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

  def load_bearing?
    load.present? || female_load.present? || male_load.present?
  end

  def max_load_prescription?
    reps.to_i.positive? &&
      duration_seconds.present? &&
      load&.zero? &&
      female_load.blank? &&
      male_load.blank?
  end

  def max_load_test?
    max_load_prescription? && workout&.max_finding?
  end

  private

  # Normalizes any lb/kg/pood load input to the canonical pounds magnitude. A unit with no fixed
  # value is a find-a-max: store the 0 sentinel so the prescription still reads as load-bearing.
  def canonicalize_load_input
    return if @load_unit.blank?

    if load.blank? && female_load.blank? && male_load.blank?
      self.load = 0
    else
      convert_load_attributes_to_lb
    end
    @load_unit = 'lb' # normalized; re-running is a no-op
  end

  def convert_load_attributes_to_lb
    return if @load_unit.to_s == 'lb'

    %i[load female_load male_load].each do |attribute|
      value = self[attribute]
      self[attribute] = LoadEquivalence.to_lb(value, @load_unit) if value.present?
    end
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

  def rep_prescription_metric
    return if reps.nil?

    Metric.new(measurement: :rep, value: reps.zero? ? nil : reps) # 0 is the "max reps" sentinel
  end

  def duration_prescription_metric
    return if duration_seconds.blank?

    Metric.new(measurement: :seconds, value: duration_seconds)
  end

  def load_prescription_metric
    return unless load_bearing?

    Metric.new(measurement: :lb, value: (load&.zero? ? nil : load), female_value: female_load, male_value: male_load,
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
