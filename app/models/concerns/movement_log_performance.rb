module MovementLogPerformance
  extend ActiveSupport::Concern

  included do
    enum :load_unit, { lb: 0, kg: 1 }, prefix: :load_unit
    enum :distance_unit, { meter: 0, foot: 1, inch: 2 }, prefix: :distance_unit

    before_validation :clear_blank_performance_units
  end

  # Recorded performance built from the movement log's columns as in-memory Metric objects. Shares
  # the `prescription_metrics` name with Exercise so rendering and scoring read both through one
  # interface. Memoized so object-identity comparisons in the helper stay stable.
  def prescription_metrics
    @prescription_metrics ||= [rep_metric, duration_metric, load_metric, distance_metric, calorie_metric].compact
  end

  # Which dimensions this recording captures — drives the recording form inputs.
  def records_reps? = reps.present?
  def records_duration? = duration_seconds.present?
  def records_load? = load_unit.present? || load.present?
  def records_distance? = distance_unit.present? || distance.present?
  def records_calories? = calories.present?

  private

  # The recording form always submits a unit (defaulting to lb/meter) for every movement log, so a
  # dimension the athlete left blank would otherwise persist an orphan unit and build a stray metric.
  def clear_blank_performance_units
    if load.blank?
      self.load_unit = nil
      self.implement_count = nil
    end
    self.distance_unit = nil if distance.blank?
  end

  def rep_metric = (Metric.new(measurement: :rep, value: reps) if records_reps?)
  def duration_metric = (Metric.new(measurement: :seconds, value: duration_seconds) if records_duration?)

  def load_metric
    Metric.new(measurement: load_unit || :lb, value: load, implement_count: implement_count) if records_load?
  end

  def calorie_metric = (Metric.new(measurement: :calorie, value: calories) if records_calories?)

  def distance_metric
    Metric.new(measurement: distance_unit || :distance, value: distance) if records_distance?
  end
end
