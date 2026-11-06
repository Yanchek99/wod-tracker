class AddIntendedStimulus < ActiveRecord::Migration[8.1]
  def change
    change_table :workouts, bulk: true do |t|
      t.integer :stimulus_range_low
      t.integer :stimulus_range_high
      t.text :intended_stimulus_notes
      t.integer :stimulus_source
    end

    change_table :exercises, bulk: true do |t|
      t.integer :stimulus_loading
      t.integer :stimulus_sets_max
      t.integer :stimulus_duration_max
      t.integer :stimulus_source
    end

    create_table :stimulus_predictions do |t|
      t.references :workout, foreign_key: true, index: false
      t.references :exercise, foreign_key: true, index: false
      t.integer :source, null: false
      t.string :model_version, null: false
      t.decimal :confidence, precision: 4, scale: 3
      t.integer :stimulus_range_low
      t.integer :stimulus_range_high
      t.integer :stimulus_loading
      t.integer :stimulus_sets_max
      t.integer :stimulus_duration_max
      t.boolean :current, null: false, default: false

      t.timestamps
    end

    add_check_constraint :stimulus_predictions,
                         'num_nonnulls(workout_id, exercise_id) = 1',
                         name: 'stimulus_predictions_exactly_one_target'

    add_index :stimulus_predictions, :workout_id,
              where: 'current', name: 'index_stimulus_predictions_current_workout'
    add_index :stimulus_predictions, :exercise_id,
              where: 'current', name: 'index_stimulus_predictions_current_exercise'
    add_index :stimulus_predictions, %i[workout_id model_version created_at],
              name: 'index_stimulus_predictions_workout_history'
    add_index :stimulus_predictions, %i[exercise_id model_version created_at],
              name: 'index_stimulus_predictions_exercise_history'
  end
end
