module PersonalRecordsHelper
  # reps: 0 is this app's existing convention for "uncapped/unspecified reps" (see the
  # "max reps X" prescription pattern in MeasurableHelper), not a literal zero-rep set -- label it
  # explicitly rather than rendering "0RM" or leaving it blank next to labeled sibling rows.
  def rep_max_label(movement_log)
    return if movement_log.reps.blank?
    return 'Max' if movement_log.reps.zero?

    "#{movement_log.reps}RM"
  end

  def rep_max_load_msg(movement_log)
    pluralize(load_input_value(movement_log.load).to_i, load_display_unit)
  end

  # measurable_additional_metrics always parenthesizes its output, since it's meant to trail a
  # reps message (e.g. "10 Rows (20 calories / 135 lbs)"). A pure distance/duration test with no
  # reps has nothing for those parens to trail, so render the bare metrics instead.
  def record_msg(movement_log)
    reps_msg = measurable_reps_msg(movement_log)
    return "#{reps_msg} #{measurable_additional_metrics(movement_log)}".strip if reps_msg

    additional_metrics(movement_log).map { |metric| metric_unit_msg(metric) }.join(' / ')
  end

  DISTANCE_UNIT_ABBREVIATIONS = { 'meter' => 'm', 'foot' => 'ft', 'inch' => 'in' }.freeze

  def distance_label(movement_log)
    unit = (movement_log.distance_unit || 'meter').to_s
    "#{movement_log.distance.to_i}#{DISTANCE_UNIT_ABBREVIATIONS.fetch(unit, unit)}"
  end

  def duration_msg(movement_log)
    duration_metric_msg(Metric.new(measurement: :seconds, value: movement_log.duration_seconds))
  end
end
