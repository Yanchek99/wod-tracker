class ScopeExercisePositionUniquenessToSegments < ActiveRecord::Migration[8.1]
  class MigrationExercise < ActiveRecord::Base
    self.table_name = 'exercises'
    self.record_timestamps = false
  end

  def up
    remove_index :exercises, column: [:position, :workout_id], name: 'index_exercises_on_position_and_workout_id'
    reset_positions

    add_index :exercises, [:position, :workout_id],
              unique: true,
              where: 'segment_id IS NULL',
              name: 'index_exercises_on_position_and_workout_id'
    add_index :exercises, [:position, :segment_id],
              unique: true,
              where: 'segment_id IS NOT NULL',
              name: 'index_exercises_on_position_and_segment_id'
  end

  def down
    remove_index :exercises, name: 'index_exercises_on_position_and_segment_id'
    remove_index :exercises, name: 'index_exercises_on_position_and_workout_id'

    add_index :exercises, [:position, :workout_id],
              unique: true,
              name: 'index_exercises_on_position_and_workout_id'
  end

  private

  def reset_positions
    say_with_time 'Resetting exercise positions within their ordering scopes' do
      reset_top_level_positions
      reset_segment_positions
    end
  end

  def reset_top_level_positions
    MigrationExercise.where(segment_id: nil).distinct.pluck(:workout_id).each do |workout_id|
      reset_scope_positions(MigrationExercise.where(workout_id:, segment_id: nil))
    end
  end

  def reset_segment_positions
    MigrationExercise.where.not(segment_id: nil).distinct.pluck(:segment_id).each do |segment_id|
      reset_scope_positions(MigrationExercise.where(segment_id:))
    end
  end

  def reset_scope_positions(scope)
    scope.order(:position, :id).pluck(:id).each.with_index(1) do |id, position|
      MigrationExercise.find(id).update!(position:)
    end
  end
end
