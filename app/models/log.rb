class Log < ApplicationRecord
  include LogScoring

  belongs_to :user, default: -> { Current.user }
  belongs_to :workout
  has_one :metric, as: :measurable, dependent: :destroy
  has_many :exercises, through: :workout
  has_many :movement_logs, dependent: :destroy

  accepts_nested_attributes_for :metric
  accepts_nested_attributes_for :movement_logs, allow_destroy: true

  enum :score_type, Metric.measurements, prefix: :score

  before_validation :copy_legacy_metric_score

  validates :score_type, presence: true

  def build_movement_logs
    workout.exercises_for_log_recording.each do |exercise|
      build_movement_log_for(exercise)
    end
  end

  def score_type
    super || metric&.measurement
  end

  def score_value
    super || metric&.value
  end

  def score_value=(new_value)
    super
    return unless new_value.is_a?(String)

    if new_value.include? ':'
      minutes, seconds = new_value.split(':', 2)
      super((minutes.to_i.minute + seconds.to_i.second).second)
    elsif score_type == 'time'
      super(new_value.to_i)
    end
  end

  def score_metric
    return unless score_type

    Metric.new(measurement: score_type, value: score_value)
  end

  private

  def copy_legacy_metric_score
    return unless metric

    self.score_type ||= metric.measurement
    self.score_value ||= metric.value
  end

  def build_movement_log_for(exercise)
    movement_log = movement_logs.build(movement: exercise.movement)
    metrics_for_movement_log(exercise).each do |metric|
      movement_log.metrics.build(
        measurement: metric.measurement,
        value: movement_log_metric_value(metric, exercise)
      )
    end
  end

  def movement_log_metric_value(metric, exercise)
    return metric.value if workout&.set_based_lifting?

    metric.calculated_value(exercise.segment.presence || exercise.workout)
  end

  def metrics_for_movement_log(exercise)
    metrics = exercise.metrics
    return ordered_recording_metrics(metrics) unless workout.rep_scored_amrap?

    component = exercise.score_component
    return ordered_recording_metrics(metrics) unless component

    ordered_recording_metrics(metrics.reject do |metric|
      metric.rep? && component[:measurement] != 'rep'
    end)
  end

  def ordered_recording_metrics(metrics)
    metrics.sort_by { |metric| [Metric.recording_order(metric.measurement), metric.id || 0] }
  end
end
