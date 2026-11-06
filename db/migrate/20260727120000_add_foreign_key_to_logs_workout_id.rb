class AddForeignKeyToLogsWorkoutId < ActiveRecord::Migration[8.1]
  def up
    guard_against_orphaned_logs!

    add_foreign_key :logs, :workouts
  end

  def down
    remove_foreign_key :logs, :workouts
  end

  private

  # Plain SQL rather than the Log/Workout models: this runs on databases that may be behind on
  # later migrations, and the models' current enums/attributes can reference columns those add.
  def guard_against_orphaned_logs!
    orphaned_count = select_value(<<~SQL.squish).to_i
      SELECT COUNT(*) FROM logs LEFT JOIN workouts ON workouts.id = logs.workout_id WHERE workouts.id IS NULL
    SQL
    return if orphaned_count.zero?

    raise "#{orphaned_count} log(s) reference a workout_id with no matching workout (inspect via " \
          '`SELECT logs.* FROM logs LEFT JOIN workouts ON workouts.id = logs.workout_id ' \
          'WHERE workouts.id IS NULL`) -- delete or reassign them before re-running this migration.'
  end
end
