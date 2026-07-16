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
end
