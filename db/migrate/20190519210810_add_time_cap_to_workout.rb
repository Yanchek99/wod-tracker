class AddTimeCapToWorkout < ActiveRecord::Migration[5.2]
  def change
    add_column :workouts, :time_cap_seconds, :integer
  end
end
