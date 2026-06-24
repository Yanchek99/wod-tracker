require 'test_helper'

class ExerciseImplementCountTest < ActiveSupport::TestCase
  test 'rejects a non-positive implement count' do
    exercise = workouts(:fran).exercises.build(movement: movements(:pullup), position: 3,
                                               load_unit: :lb, load: 50, implement_count: 0)

    assert_not exercise.valid?
    assert exercise.errors[:implement_count].present?
  end

  test 'leaves the implement count unset by default' do
    assert_nil Exercise.new.implement_count
  end

  test 'allows a movement without an implement count or load' do
    exercise = workouts(:fran).exercises.build(movement: movements(:pullup), position: 3, reps: 21)

    assert_nil exercise.implement_count
    assert_predicate exercise, :valid?
  end

  test 'requires a load when more than one implement is configured' do
    exercise = workouts(:fran).exercises.build(movement: movements(:pullup), position: 3,
                                               reps: 21, implement_count: 2)

    assert_not exercise.valid?
    assert_includes exercise.errors[:implement_count], 'requires a load'
  end

  test 'allows an implement count alongside a load' do
    exercise = workouts(:fran).exercises.build(movement: movements(:pullup), position: 3,
                                               load_unit: :lb, load: 50, implement_count: 2)

    assert_predicate exercise, :valid?
  end
end
