require 'test_helper'
require Rails.root.join('db/migrate/20260713150000_drop_workout_scheme_and_exercise_workout_id').to_s

class DropWorkoutSchemeAndExerciseWorkoutIdTest < ActiveSupport::TestCase
  test 'exercises.segment_id rejects null at the database level after the migration' do
    assert_raises(ActiveRecord::NotNullViolation) do
      ActiveRecord::Base.connection.execute(
        'INSERT INTO exercises (movement_id, position, created_at, updated_at) ' \
        "VALUES (#{movements(:run).id}, 999, NOW(), NOW())"
      )
    end
  end

  test 'up raises a deliberate error instead of a raw NOT NULL violation when an orphaned exercise remains' do
    ActiveRecord::Base.connection.change_column_null :exercises, :segment_id, true
    # rubocop:disable Rails/SkipsModelValidations
    Exercise.insert!(
      { movement_id: movements(:run).id, position: 999, created_at: Time.current, updated_at: Time.current }
    )
    # rubocop:enable Rails/SkipsModelValidations

    error = assert_raises(RuntimeError) do
      DropWorkoutSchemeAndExerciseWorkoutId.new.send(:guard_against_orphaned_exercises!)
    end
    assert_match(/nil segment_id/, error.message)
  ensure
    Exercise.unscoped.where(segment_id: nil).delete_all
    ActiveRecord::Base.connection.change_column_null :exercises, :segment_id, false
  end
end
