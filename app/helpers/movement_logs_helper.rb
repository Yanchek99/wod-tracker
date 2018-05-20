module MovementLogsHelper
  def movement_log_summary(movement_log)
    measurement_summary = " @ #{pluralize movement_log.measurement_value, movement_log.measurement.unit}" unless movement_log.measurement.rep?
    "#{pluralize movement_log.reps, movement_log.movement.name}#{measurement_summary}"
  end
end
