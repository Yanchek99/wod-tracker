class ScopeExercisePositionUniquenessToSegments < ActiveRecord::Migration[8.1]
  def change
    remove_index :exercises, column: [:position, :workout_id], name: 'index_exercises_on_position_and_workout_id'

    add_index :exercises, [:position, :workout_id],
              unique: true,
              where: 'segment_id IS NULL',
              name: 'index_exercises_on_position_and_workout_id'
    add_index :exercises, [:position, :segment_id],
              unique: true,
              where: 'segment_id IS NOT NULL',
              name: 'index_exercises_on_position_and_segment_id'
  end
end
