class AddTeamSizeToWorkouts < ActiveRecord::Migration[8.1]
  def up
    add_column :workouts, :team_size, :integer

    # team_size now participates in the content fingerprint, so existing keys are
    # stale. Recompute through the model so the fingerprint stays the single source
    # of truth (a nil key for a workout with no parts is left distinct).
    Workout.reset_column_information
    Workout.find_each { |workout| workout.update_column(:content_key, workout.content_fingerprint) }
  end

  def down
    remove_column :workouts, :team_size
  end
end
