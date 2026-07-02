module MovementLogPerformance
  extend ActiveSupport::Concern

  included do
    enum :distance_unit, { meter: 0, foot: 1, inch: 2 }, prefix: :distance_unit

    before_validation :canonicalize_load_input
    before_validation :clear_blank_performance_units
  end

  # Transient input unit (lb/kg/pood) for a recorded load. Loads are stored canonically in pounds
  # (see cf/docs/load-and-distance-equivalence.md), so this is normalized away on save.
  attr_writer :load_unit

  def load_unit = @load_unit

  # Recorded performance built from the movement log's columns as in-memory Metric objects. Shares
  # the `prescription_metrics` name with Exercise so rendering and scoring read both through one
  # interface. Memoized so object-identity comparisons in the helper stay stable.
  def prescription_metrics
    @prescription_metrics ||= [rep_metric, duration_metric, load_metric, distance_metric, calorie_metric].compact
  end

  # Which dimensions this recording captures — drives the recording form inputs.
  def records_reps? = reps.present?
  def records_duration? = duration_seconds.present?
  def records_load? = load.present?
  def records_distance? = distance_unit.present? || distance.present?
  def records_calories? = calories.present?

  private

  def canonicalize_load_input
    return if @load_unit.blank?

    self.load = LoadEquivalence.to_lb(load, @load_unit) if load.present? && @load_unit.to_s != 'lb'
    @load_unit = 'lb'
  end

  # The recording form always submits a unit for distance, so a dimension the athlete left blank
  # would otherwise persist an orphan marker and build a stray metric.
  def clear_blank_performance_units
    self.implement_count = nil if load.blank?
    self.distance_unit = nil if distance.blank?
  end

  def rep_metric = (Metric.new(measurement: :rep, value: reps) if records_reps?)
  def duration_metric = (Metric.new(measurement: :seconds, value: duration_seconds) if records_duration?)

  def load_metric
    Metric.new(measurement: :lb, value: load, implement_count: implement_count) if records_load?
  end

  def calorie_metric = (Metric.new(measurement: :calorie, value: calories) if records_calories?)

  def distance_metric
    Metric.new(measurement: distance_unit || :distance, value: distance) if records_distance?
  end
end
