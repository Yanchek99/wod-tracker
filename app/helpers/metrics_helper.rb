module MetricsHelper
  HEIGHT_MEASUREMENTS = %w[foot inch].freeze

  def metric_unit_msg(metric)
    "#{implement_count_prefix(metric)}#{metric_value_msg(metric)}"
  end

  # `2×` qualifier for load held in multiple implements (e.g. double-dumbbell). Renders before the
  # load so `♀35lb / ♂50lb` dumbbells become `2×♀35lb / ♂50lb`.
  def implement_count_prefix(metric)
    return '' unless metric.respond_to?(:multiple_implements?) && metric.multiple_implements?

    "#{metric.implement_count}×"
  end

  def metric_value_msg(metric)
    return sex_specific_metric_unit_msg(metric) if metric.sex_specific?
    return "#{metric.value.to_i} ft" if metric.foot? # Rails has no foot -> feet inflection
    return pluralize(1, metric.measurement) if metric.value.nil?
    return rep_count_msg(metric) if metric.rep?
    return seconds_to_duration_string(metric.value) if metric.seconds? || metric.time?

    pluralize(metric.value.to_i, metric.measurement)
  end

  def rep_count_msg(metric) = metric.value == 1 ? '' : metric.value

  def log_score_msg(log)
    return unless log.score_measurement

    score_metric = Metric.new(measurement: log.score_measurement, value: log.score_value)
    amrap_score_msg(log) || rep_score_msg(score_metric) || metric_unit_msg(score_metric)
  end

  def amrap_score_msg(log)
    parts = log.amrap_score_parts
    return unless parts

    if parts[:reps].zero?
      "#{pluralize(parts[:rounds], 'round')} (#{pluralize(parts[:total], 'rep')})"
    else
      "#{parts[:rounds]} + #{parts[:reps]} (#{pluralize(parts[:total], 'rep')})"
    end
  end

  def rep_score_msg(metric)
    return unless metric.rep? && metric.value.present?

    pluralize(metric.value, 'rep')
  end

  def seconds_to_duration_string(seconds)
    duration = ActiveSupport::Duration.build(seconds).parts
    format '%<hours>02d:%<minutes>02d:%<seconds>02d',
           hours: duration.fetch(:hours, 0),
           minutes: duration.fetch(:minutes, 0),
           seconds: duration.fetch(:seconds, 0)
  end

  def sex_specific_metric_unit_msg(metric)
    unit = metric.measurement.singularize
    separator = Metric::LOAD_MEASUREMENTS.include?(unit) ? '' : '-'

    "♀#{metric.female_value}#{separator}#{unit} / ♂#{metric.male_value}#{separator}#{unit}"
  end

  def additional_metric_display_order(metric)
    return [2, 0] if HEIGHT_MEASUREMENTS.include?(metric.measurement) # target height is a qualifier
    return [0, 1] if metric.calorie? || Metric::DISTANCE_MEASUREMENTS.include?(metric.measurement)
    return [1, 0] if Metric::LOAD_MEASUREMENTS.include?(metric.measurement)

    [1, 1]
  end

  def sex_specific_metric_display_order(metric)
    return [0, 1] if Metric::LOAD_MEASUREMENTS.include?(metric.measurement)
    return [1, 0] if Metric::DISTANCE_MEASUREMENTS.include?(metric.measurement)

    [1, 1]
  end
end
