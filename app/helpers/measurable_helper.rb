module MeasurableHelper
  def measurable_message(measurable)
    [measurable_movement_msg(measurable), measurable_additional_metrics(measurable)].compact.join(' ')
  end

  def measurable_movement_msg(measurable)
    movement_name = measurable.movement.name
    return movement_name.pluralize if measurable.try(:ladder_participant?)

    rep_metric = measurable.prescription_metrics.find(&:rep?)
    duration_metric = duration_metric(measurable)
    return duration_movement_msg(measurable, rep_metric, duration_metric) if duration_metric

    lead_metric = leading_work_metric(measurable)
    return leading_work_movement_msg(measurable, lead_metric) if lead_metric

    return movement_name unless rep_metric
    return "max reps #{movement_name}" if max_rep_metric?(rep_metric)

    [metric_unit_msg(rep_metric), movement_name_for_rep_metric(movement_name, rep_metric)].compact_blank.join(' ')
  end

  def measurable_reps_msg(measurable)
    rep_metric = measurable.prescription_metrics.find(&:rep?)
    metric_unit_msg(rep_metric)
  end

  def measurable_additional_metrics(measurable)
    metrics = additional_metrics(measurable)
    return if metrics.empty?
    return "(#{sex_specific_metrics_msg(metrics)})" if grouped_sex_specific_metrics?(metrics)

    "(#{metrics.map { |metric| metric_unit_msg(metric) }.join(' / ')})"
  end

  def additional_metrics(measurable)
    leading_work_metric = leading_work_metric(measurable)

    measurable.prescription_metrics.reject(&:rep?)
              .reject { |metric| metric == leading_work_metric }
              .reject { |metric| duration_metric?(metric) }
              .select { |metric| visible_metric?(metric) }
              .sort_by { |metric| additional_metric_display_order(metric) }
  end

  def grouped_sex_specific_metrics?(metrics)
    metrics.length > 1 && metrics.all?(&:sex_specific?)
  end

  def visible_metric?(metric) = metric.value.present? || metric.sex_specific?

  def duration_metric(measurable)
    measurable.prescription_metrics.find { |metric| duration_metric?(metric) && metric.value.present? }
  end

  def duration_metric?(metric) = metric.seconds? || metric.time?

  def movement_name_for_rep_metric(movement_name, metric)
    pluralize_movement?(metric) ? movement_name.pluralize : movement_name
  end

  def sex_specific_metrics_msg(metrics)
    ordered_metrics = metrics.sort_by { |metric| sex_specific_metric_display_order(metric) }
    female_values = ordered_metrics.map { |metric| sex_specific_metric_value_msg(metric, metric.female_value) }
    male_values = ordered_metrics.map { |metric| sex_specific_metric_value_msg(metric, metric.male_value) }

    "♀#{female_values.join(' + ')} / ♂#{male_values.join(' + ')}"
  end

  def sex_specific_metric_value_msg(metric, value)
    unit = grouped_metric_unit(metric)
    separator = Metric::LOAD_MEASUREMENTS.include?(unit) || unit == 'ft' ? '' : '-'

    "#{value}#{separator}#{unit}"
  end

  def grouped_metric_unit(metric)
    return 'ft' if metric.foot?

    metric.measurement.singularize
  end

  def pluralize_movement?(metric)
    return metric.value > 1 if metric.value.present?
    return [metric.female_value, metric.male_value].compact.max > 1 if metric.sex_specific?

    false
  end

  def max_rep_metric?(metric) = metric.rep? && metric.value.blank? && !metric.sex_specific?

  def duration_movement_msg(measurable, rep_metric, duration_metric)
    movement_name = duration_pluralize_movement?(rep_metric) ? measurable.movement.name.pluralize : measurable.movement.name

    [duration_metric_msg(duration_metric), movement_name].join(' ')
  end

  def duration_pluralize_movement?(rep_metric) = rep_metric.present? && rep_metric.value.blank?

  def duration_metric_msg(metric)
    total_seconds = metric.value.to_i
    hours, remainder = total_seconds.divmod(3600)
    minutes, seconds = remainder.divmod(60)

    return format('%<hours>d:%<minutes>02d:%<seconds>02d', hours: hours, minutes: minutes, seconds: seconds) if hours.positive?

    format('%<minutes>d:%<seconds>02d', minutes: minutes, seconds: seconds)
  end

  def leading_work_metric(measurable)
    return unless measurable.is_a?(Exercise)

    metrics = measurable.prescription_metrics
    candidate = metrics.find { |metric| leading_work_candidate?(metric) }
    candidate if leading_work_metric_stands_alone?(candidate, metrics)
  end

  def leading_work_candidate?(metric) = visible_metric?(metric) && leading_work_metric?(metric)

  def leading_work_metric_stands_alone?(candidate, metrics)
    candidate && metrics.all? { |metric| !visible_metric?(metric) || metric == candidate || structural_single_rep_metric?(metric) }
  end

  def leading_work_metric?(metric) = metric.calorie? || Metric::DISTANCE_MEASUREMENTS.include?(metric.measurement)

  def structural_single_rep_metric?(metric) = metric.rep? && metric.value == 1

  def leading_work_movement_msg(measurable, metric)
    [leading_work_metric_msg(metric), measurable.movement.name].join(' ')
  end

  def leading_work_metric_msg(metric)
    return sex_specific_leading_work_metric_msg(metric) if metric.sex_specific?

    "#{metric.value} #{metric.measurement.singularize}"
  end

  def sex_specific_leading_work_metric_msg(metric)
    "#{metric.male_value}/#{metric.female_value} #{metric.measurement.singularize}"
  end
end
