class AddAscendingLadderColumns < ActiveRecord::Migration[8.1]
  def change
    # Workout-level per-round increment for an ascending ladder; the start comes from each
    # participating exercise's reps.
    add_column :workouts, :ladder_step, :integer
    # Rounds between increments for an exercise (blank = grow every round), and a flag for a
    # movement that stays constant rather than riding the ladder.
    add_column :exercises, :ladder_step_every, :integer
    add_column :exercises, :ladder_exempt, :boolean, default: false, null: false
  end
end
