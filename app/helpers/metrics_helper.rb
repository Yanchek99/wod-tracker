module MetricsHelper
  def measurement_value_input_html(metric)
    return { class: 'reps-field', data: { original_reps: metric.value } } if metric.rep?

    {}
  end

  def metric_unit_msg(metric)
    return "Max #{metric.measurement.pluralize}" if metric.value.nil?
    return metric.value == 1 ? '' : metric.value if metric.rep?
    return seconds_to_duration_string(metric.value) if metric.seconds?
    return seconds_to_duration_string(metric.value) if metric.time?

    pluralize metric.value, metric.measurement
  end

  def seconds_to_duration_string(seconds)
    duration = ActiveSupport::Duration.build(seconds).parts
    "#{format '%02d', duration[:minutes]}:#{format '%02d', duration[:seconds]}"
  end
end
