module MovementLogPerformance
  extend ActiveSupport::Concern

  # Columns that indicate a movement log carries its performance directly (not via legacy metrics).
  DIRECT_PERFORMANCE_COLUMNS = %i[
    reps duration_seconds load load_unit distance distance_unit calories
  ].freeze

  included do
    enum :load_unit, { lb: 0, kg: 1 }, prefix: :load_unit
    enum :distance_unit, { meter: 0, foot: 1, inch: 2 }, prefix: :distance_unit

    before_validation :clear_blank_performance_units
  end

  # Recorded performance as in-memory Metric objects, preferring the direct columns and falling
  # back to legacy metric rows while both exist (removed in a later phase). Shares the
  # `prescription_metrics` name with Exercise so rendering and scoring read both through one
  # interface. Memoized so object-identity comparisons in the helper stay stable.
  def prescription_metrics
    @prescription_metrics ||= build_performance_metrics
  end

  def uses_direct_performance?
    DIRECT_PERFORMANCE_COLUMNS.any? { |column| self[column].present? }
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
    self.load_unit = nil if load.blank?
    self.distance_unit = nil if distance.blank?
  end

  def build_performance_metrics
    return metrics.to_a unless uses_direct_performance?

    [rep_metric, duration_metric, load_metric, distance_metric, calorie_metric].compact
  end

  def rep_metric = (Metric.new(measurement: :rep, value: reps) if records_reps?)
  def duration_metric = (Metric.new(measurement: :seconds, value: duration_seconds) if records_duration?)
  def load_metric = (Metric.new(measurement: load_unit || :lb, value: load) if records_load?)
  def calorie_metric = (Metric.new(measurement: :calorie, value: calories) if records_calories?)

  def distance_metric
    Metric.new(measurement: distance_unit || :distance, value: distance) if records_distance?
  end
end
