module PersonalRecordsHelper
  def rep_max_label(movement_log)
    return unless movement_log.reps

    "#{movement_log.reps}RM"
  end

  def rep_max_load_msg(movement_log)
    pluralize(load_input_value(movement_log.load).to_i, load_display_unit)
  end
end
