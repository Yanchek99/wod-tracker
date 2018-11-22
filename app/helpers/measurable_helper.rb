module MeasurableHelper
  def measurable_message(measurable)
    "#{measurable_movement_msg(measurable)}#{measurable_measurement_unit_msg(measurable)}"
  end

  def measurable_movement_msg(measurable)
    rep_value = measurable.metrics.find_by(measurement: :rep)&.value
    return "Max reps #{measurable.movement.name}" if rep_value.nil?
    return measurable.movement.name if rep_value.to_i == 1

    pluralize(rep_value.to_i, measurable.movement.name)
  end

  def measurable_reps_msg(measurable)
    rep_metric = measurable.metrics.find_by(measurement: :rep)
    return '1 rep' unless rep_metric
    return 'Max reps' if rep_metric.value.nil?

    pluralize(rep_metric.value.to_i, 'rep')
  end

  def measurable_measurement_unit_msg(measurable)
    msg = ''
    measurable.metrics.where.not(measurement: :rep).each do |metric|
      msg << " / #{pluralize formatted_metric_value(metric), metric.unit}"
    end
    msg
  end
end
