module MetricsHelper
  def measurement_value_input_html(metric)
    return { class: 'reps-field', data: { original_reps: metric.value } } if metric.rep?

    {}
  end

  def metric_unit_msg(metric)
    return pluralize(1, metric.measurement) if metric.value.nil?
    return metric.value == 1 ? '' : metric.value if metric.rep?
    return seconds_to_duration_string(metric.value) if metric.seconds? || metric.time?

    pluralize(metric.value.to_i, metric.measurement)
  end

  def log_score_msg(log)
    return unless log.metric

    amrap_score_msg(log) || rep_score_msg(log.metric) || metric_unit_msg(log.metric)
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
end
