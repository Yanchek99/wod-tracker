module MeasurableHelper
  def measurable_message(measurable)
    "#{measurable_movement_msg(measurable)}#{measurable_additional_metrics(measurable)}"
  end

  def measurable_movement_msg(measurable)
    rep_metric = measurable.metrics.find_by(measurement: :rep)
    return measurable.movement.name unless rep_metric

    movement_name = measurable.movement.name
    "#{metric_unit_msg rep_metric} #{(rep_metric.value || 0) > 1 ? movement_name.pluralize : movement_name}"
  end

  def measurable_reps_msg(measurable)
    rep_metric = measurable.metrics.find_by(measurement: :rep)
    metric_unit_msg(rep_metric)
  end

  def measurable_additional_metrics(measurable)
    msg = ''
    measurable.metrics.where.not(measurement: :rep).each do |metric|
      msg << " / #{metric_unit_msg(metric)}"
    end
    msg
  end
end
