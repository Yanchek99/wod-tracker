module MetricsHelper
  def measurement_value_input_html(metric)
    return { class: 'reps-field', data: { original_reps: metric.value } } if metric.rep?

    {}
  end

  def metric_unit_msg(metric)
    return "Max #{metric.unit.pluralize}" if metric.value.nil?
    return metric.value == 1 ? "" : metric.value if metric.rep?
    pluralize formatted_metric_value(metric), metric.unit
  end

  def formatted_metric_value(metric)
    return metric.value unless metric.time?

    duration = ActiveSupport::Duration.build(metric.value).parts
    "#{format '%02d', duration[:minutes]}:#{format '%02d', duration[:seconds]}"
  end
end
