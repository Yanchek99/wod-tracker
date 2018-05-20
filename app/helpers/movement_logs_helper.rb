module MovementLogsHelper
  def movement_log_summary(movement_log)
    "#{movement_log.movement.name} @ #{pluralize movement_log.measurement_value, movement_log.measurement.unit}"
  end
end
