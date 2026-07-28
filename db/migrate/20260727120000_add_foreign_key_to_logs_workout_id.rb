class AddForeignKeyToLogsWorkoutId < ActiveRecord::Migration[8.1]
  def up
    guard_against_orphaned_logs!

    add_foreign_key :logs, :workouts
  end

  def down
    remove_foreign_key :logs, :workouts
  end

  private

  def guard_against_orphaned_logs!
    orphaned_count = Log.unscoped.orphaned.count
    return if orphaned_count.zero?

    raise "#{orphaned_count} log(s) reference a workout_id with no matching workout (inspect via " \
          '`Log.orphaned`, or the "Orphaned" scope in RailsAdmin) -- delete or reassign them before ' \
          're-running this migration.'
  end
end
