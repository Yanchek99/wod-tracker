class RequireMovementOnExercises < ActiveRecord::Migration[8.1]
  def change
    change_column_null :exercises, :movement_id, false
  end
end
