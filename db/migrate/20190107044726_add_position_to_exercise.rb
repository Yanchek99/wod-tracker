class AddPositionToExercise < ActiveRecord::Migration[5.2]
  def change
    add_column :exercises, :position, :integer
  end
end
