class RemoveOldMeasurements < ActiveRecord::Migration[5.2]
  def change
    remove_column :exercises, :reps, :integer
    remove_column :movement_logs, :reps, :integer
    remove_column :exercises, :measurement_value, :string
    remove_column :movement_logs, :measurement_value, :string
    remove_column :exercises, :measurement_id, :integer
    remove_column :movement_logs, :measurement_id, :integer
    remove_column :workouts, :measurement_id, :integer
    remove_column :logs, :measurement_value
    drop_table :measurements do |t|
      t.string :name

      t.timestamps
    end
  end
end
