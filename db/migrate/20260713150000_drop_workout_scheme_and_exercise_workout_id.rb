class DropWorkoutSchemeAndExerciseWorkoutId < ActiveRecord::Migration[8.1]
  def up
    guard_against_orphaned_exercises!

    change_column_null :exercises, :segment_id, false

    remove_index :exercises, name: 'index_exercises_on_position_and_workout_id'
    remove_index :exercises, name: 'index_exercises_on_position_and_segment_id'
    add_index :exercises, %i[position segment_id], unique: true, name: 'index_exercises_on_position_and_segment_id'

    remove_foreign_key :exercises, :workouts
    remove_column :exercises, :workout_id

    change_table :workouts, bulk: true do |t|
      t.remove :rounds
      t.remove :time
      t.remove :interval
    end
  end

  def down
    change_table :workouts, bulk: true do |t|
      t.column :interval, :string
      t.column :time, :integer
      t.column :rounds, :integer
    end

    add_column :exercises, :workout_id, :bigint
    add_foreign_key :exercises, :workouts

    remove_index :exercises, name: 'index_exercises_on_position_and_segment_id'
    add_index :exercises, %i[position segment_id], unique: true, where: 'segment_id IS NOT NULL',
                                                   name: 'index_exercises_on_position_and_segment_id'
    add_index :exercises, %i[position workout_id], unique: true, where: 'segment_id IS NULL',
                                                   name: 'index_exercises_on_position_and_workout_id'

    change_column_null :exercises, :segment_id, true

    say 'workouts.rounds/time/interval and exercises.workout_id are restored as empty columns -- ' \
        'historical values are not recoverable (they were already migrated into segments by ' \
        'BackfillSegmentsForTopLevelExercises in Task 1, whose own #down is likewise a no-op).'
  end

  private

  def guard_against_orphaned_exercises!
    orphaned_count = Exercise.unscoped.where(segment_id: nil).count
    return if orphaned_count.zero?

    raise "#{orphaned_count} exercise(s) still have a nil segment_id (inspect via " \
          '`Exercise.unscoped.where(segment_id: nil)`). BackfillSegmentsForTopLevelExercises does not ' \
          'backfill exercises that also have no workout_id (legacy/malformed data it deliberately ' \
          'ignores) -- investigate and resolve these rows manually before re-running this migration.'
  end
end
