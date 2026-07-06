module MeasurablePrescribedWorkHelper
  def prescribed_work_metric(measurable)
    return unless measurable.is_a?(Exercise)

    metrics = measurable.prescription_metrics
    candidate = metrics.find { |metric| prescribed_work_candidate?(metric) }
    candidate if prescribed_work_metric_stands_alone?(candidate, metrics)
  end

  def prescribed_work_candidate?(metric) = visible_metric?(metric) && prescribed_work_metric?(metric)

  def prescribed_work_metric_stands_alone?(candidate, metrics)
    candidate && metrics.all? do |metric|
      !visible_metric?(metric) ||
        metric == candidate ||
        structural_single_rep_metric?(metric) ||
        load_detail_for_prescribed_work?(candidate, metric, metrics)
    end
  end

  def prescribed_work_metric?(metric) = metric.calorie? || Metric::DISTANCE_MEASUREMENTS.include?(metric.measurement)

  def structural_single_rep_metric?(metric) = metric.rep? && metric.value == 1

  def load_detail_for_prescribed_work?(candidate, metric, metrics)
    prescribed_work_metric?(candidate) &&
      Metric::LOAD_MEASUREMENTS.include?(metric.measurement) &&
      (candidate.value.present? || metrics.any? { |other_metric| structural_single_rep_metric?(other_metric) })
  end

  def prescribed_work_movement_msg(measurable, metric)
    [prescribed_work_metric_msg(metric), measurable.movement.name].join(' ')
  end

  def prescribed_work_metric_msg(metric)
    return sex_specific_prescribed_work_metric_msg(metric) if metric.sex_specific?

    "#{metric.value}#{prescribed_work_metric_unit_msg(metric)}"
  end

  def sex_specific_prescribed_work_metric_msg(metric)
    "#{metric.male_value}/#{metric.female_value}#{prescribed_work_metric_unit_msg(metric)}"
  end

  def prescribed_work_metric_unit_msg(metric)
    metric.foot? ? 'ft' : " #{metric.measurement.singularize}"
  end
end
