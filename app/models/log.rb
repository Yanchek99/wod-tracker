class Log < ApplicationRecord
  include LogScoring

  belongs_to :user, default: -> { Current.user }
  belongs_to :workout
  has_many :exercises, through: :workout
  has_many :movement_logs, dependent: :destroy

  accepts_nested_attributes_for :movement_logs, allow_destroy: true

  enum :score_type, Metric.measurements, prefix: :score

  validates :score_type, presence: true

  before_save :backfill_lifting_loads_from_score

  def build_movement_logs
    workout.exercises_for_log_recording.each do |exercise|
      build_movement_log_for(exercise)
    end
  end

  def score_measurement
    score_type
  end

  def score_value=(new_value)
    if new_value.is_a?(String) && new_value.include?(':')
      minutes, seconds = new_value.split(':', 2)
      super((minutes.to_i.minute + seconds.to_i.second).second)
    else
      super
    end
  end

  private

  def backfill_lifting_loads_from_score
    return unless score_weight? && !workout.calculated_lifting_score? && score_value.present?

    exercises = workout.exercises_for_log_recording
    movement_logs.each_with_index do |movement_log, index|
      exercise = exercises[index]
      next unless exercise&.load_bearing? && movement_log.load.blank?

      movement_log.load = score_value
    end
  end

  def build_movement_log_for(exercise)
    movement_log = movement_logs.build(movement: exercise.movement)
    metrics_for_movement_log(exercise).each do |metric|
      assign_performance(movement_log, metric, movement_log_metric_value(metric, exercise))
    end
  end

  # Copies a selected prescription dimension onto the movement log's performance columns. reps and
  # calories have no unit, so a recorded-but-unprescribed (max-effort) dimension is stored as 0 to
  # keep the recording form input rendered; distance keeps its unit for the same reason. The
  # recording form always renders a load input regardless, so load needs no such marker.
  def assign_performance(movement_log, metric, value)
    case metric.measurement
    when 'rep' then movement_log.reps = value || 0
    when 'calorie' then movement_log.calories = value || 0
    when 'seconds', 'time' then movement_log.duration_seconds = value
    else assign_load_or_distance(movement_log, metric.measurement, value)
    end
  end

  def assign_load_or_distance(movement_log, measurement, value)
    if Metric::LOAD_MEASUREMENTS.include?(measurement)
      movement_log.load = value
    elsif Metric::DISTANCE_MEASUREMENTS.include?(measurement)
      assign_distance(movement_log, measurement, value)
    end
  end

  def assign_distance(movement_log, measurement, value)
    movement_log.distance_unit = measurement if %w[meter foot inch].include?(measurement)
    movement_log.distance = value
  end

  def movement_log_metric_value(metric, exercise)
    return metric.default_value if workout&.set_based_lifting?

    metric.calculated_value(exercise.segment)
  end

  def metrics_for_movement_log(exercise)
    metrics = recording_metrics_for(exercise)
    return ordered_recording_metrics(metrics) unless workout.rep_scored_amrap?

    component = exercise.score_component
    return ordered_recording_metrics(metrics) unless component

    ordered_recording_metrics(metrics.reject do |metric|
      metric.rep? && component[:measurement] != 'rep'
    end)
  end

  def ordered_recording_metrics(metrics)
    metrics.sort_by { |metric| Metric.recording_order(metric.measurement) }
  end

  def recording_metrics_for(exercise)
    return exercise.prescription_metrics unless exercise.max_load_test?

    exercise.prescription_metrics.reject { |metric| metric.seconds? || metric.time? }
  end
end
