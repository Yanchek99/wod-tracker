class AddMeasurementToExercise < ActiveRecord::Migration[5.2]
  def change
    add_reference :exercises, :measurement, foreign_key: true
  end
end
