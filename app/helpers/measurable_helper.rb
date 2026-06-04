module MeasurableHelper
  def measurable_message(measurable)
    [measurable_movement_msg(measurable), measurable_additional_metrics(measurable)].compact.join(' ')
  end

  def measurable_movement_msg(measurable)
    rep_metric = measurable.metrics.find_by(measurement: :rep)
    return measurable.movement.name unless rep_metric

    movement_name = measurable.movement.name
    [metric_unit_msg(rep_metric), pluralize_movement?(rep_metric) ? movement_name.pluralize : movement_name].reject(&:blank?).join(' ')
  end

  def measurable_reps_msg(measurable)
    rep_metric = measurable.metrics.find_by(measurement: :rep)
    metric_unit_msg(rep_metric)
  end

  def measurable_additional_metrics(measurable)
    metrics = measurable.metrics.where.not(measurement: :rep)
                        .select { |metric| metric.value.present? || metric.sex_specific? }
    return if metrics.empty?

    "(#{metrics.map { |metric| metric_unit_msg(metric) }.join(' / ')})"
  end

  def pluralize_movement?(metric)
    return metric.value > 1 if metric.value.present?
    return [metric.female_value, metric.male_value].compact.max > 1 if metric.sex_specific?

    false
  end
end
