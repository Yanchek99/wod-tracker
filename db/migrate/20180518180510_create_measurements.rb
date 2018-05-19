class CreateMeasurements < ActiveRecord::Migration[5.2]
  def change
    create_table :measurements do |t|
      t.string :name

      t.timestamps
    end
    rename_column :workouts, :measurement, :measurement_id
    rename_column :movements, :measurement, :measurement_id
  end
end
