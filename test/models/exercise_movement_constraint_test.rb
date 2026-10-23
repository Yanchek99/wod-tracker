require 'test_helper'

class ExerciseMovementConstraintTest < ActiveSupport::TestCase
  test 'database rejects an exercise without a movement' do
    exercise = segments(:test).exercises.create!(movement: movements(:pullup), position: 99)
    exercise.movement = nil

    assert_raises(ActiveRecord::NotNullViolation) { exercise.save!(validate: false) }
  end
end
