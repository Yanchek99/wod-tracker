module PersonalRecordsHelper
  def rep_max_label(movement_log)
    return unless movement_log.reps

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
end
