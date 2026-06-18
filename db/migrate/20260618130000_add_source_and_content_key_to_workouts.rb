class AddSourceAndContentKeyToWorkouts < ActiveRecord::Migration[8.1]
  def up
    add_column :workouts, :source, :string
    add_column :workouts, :content_key, :string
    add_index :workouts, :content_key, unique: true

    # Backfill existing workouts through the model so the fingerprint logic has a
    # single source of truth. A nil key (a workout with no parts) is left distinct.
    Workout.reset_column_information
    Workout.find_each { |workout| workout.update_column(:content_key, workout.content_fingerprint) }
  end

  def down
    remove_index :workouts, :content_key
    remove_column :workouts, :content_key
    remove_column :workouts, :source
  end
end
