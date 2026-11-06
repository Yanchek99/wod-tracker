require 'test_helper'
require Rails.root.join('db/migrate/20260727120000_add_foreign_key_to_logs_workout_id').to_s

# The orphan guard runs against databases that are behind on migrations, so it must not load the
# Workout/Log models (their enums and attributes can reference columns a later migration adds).
class AddForeignKeyToLogsWorkoutIdTest < ActiveSupport::TestCase
  setup do
    @migration = AddForeignKeyToLogsWorkoutId.new
    connection = ActiveRecord::Base.connection
    connection.remove_foreign_key :logs, :workouts if connection.foreign_key_exists?(:logs, :workouts)
  end

  test 'guard passes when every log references an existing workout' do
    assert_nothing_raised { @migration.send(:guard_against_orphaned_logs!) }
  end

  test 'guard raises with the orphan count when a log references a missing workout' do
    insert_log(workout_id: Workout.maximum(:id).to_i + 1000)

    error = assert_raises(RuntimeError) { @migration.send(:guard_against_orphaned_logs!) }
    assert_match(/1 log\(s\) reference a workout_id with no matching workout/, error.message)
  end

  private

  def insert_log(workout_id:)
    now = Time.current
    ActiveRecord::Base.connection.insert_fixture(
      { 'score_type' => 0, 'workout_id' => workout_id, 'created_at' => now, 'updated_at' => now }, 'logs'
    )
  end
end
