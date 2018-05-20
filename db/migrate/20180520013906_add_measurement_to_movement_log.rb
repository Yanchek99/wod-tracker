class AddMeasurementToMovementLog < ActiveRecord::Migration[5.2]
  def change
    add_reference :movement_logs, :measurement, foreign_key: true
  end
end
