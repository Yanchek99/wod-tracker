class RemoveMeasurementFromMovement < ActiveRecord::Migration[5.2]
  def change
    remove_column :movements, :measurement_id, :integer
  end
end
