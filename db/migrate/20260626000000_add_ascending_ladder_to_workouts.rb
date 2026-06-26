class AddAscendingLadderToWorkouts < ActiveRecord::Migration[8.1]
  def change
    add_column :workouts, :ladder_start, :integer
    add_column :workouts, :ladder_step, :integer
    add_column :exercises, :ladder_step_every, :integer
  end
end
