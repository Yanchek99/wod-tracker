module MeasurableHelper
  MESURABLE_UNITS = { calories: 'cal', distance: 'meter', height: 'inch', reps: 'rep', seconds: 's', weight: 'lb' }

  def measurable_message(measurable)
    "#{measurable_movement_msg(measurable)}#{measurable_additional_metrics(measurable)}"
  end

  def measurable_movement_msg(measurable)
    movement_name = measurable.movement.name
    return movement_name unless measurable.reps
    "#{measurable_unit_msg :reps, measurable.reps} #{(measurable.reps || 0) > 1 ? movement_name.pluralize : movement_name}"
  end

  def measurable_reps_msg(measurable)
    measurable_unit_msg(measurable.reps)
  end

  def measurable_additional_metrics(measurable)
    msg = ''
    measurable.attributes.keys.each do |attribute|
      value = measurable[attribute.to_sym]

      logger.debug "attribute #{MESURABLE_UNITS.keys}, value: #{attribute}"
      if MESURABLE_UNITS.keys.reject{|k| k.equal? :reps}.include?(attribute.to_sym) && value.present?
        msg << " / #{measurable_unit_msg(attribute, value)}"
      end
    end
    msg
  end

  def measurable_unit_msg(attribute, value)
    unit = MESURABLE_UNITS[attribute.to_sym]
    return "Max #{unit.pluralize}" if value.zero?
    return value == 1 ? "" : value if attribute.equal? :reps
    pluralize value, unit
  end
end
