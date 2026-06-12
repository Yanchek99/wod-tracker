require 'test_helper'

class SegmentTest < ActiveSupport::TestCase
  test 'assigns the next workout part position when omitted' do
    segment = workouts(:segmented).segments.build

    assert segment.valid?
    assert_equal 4, segment.position
  end

  test 'rejects duplicate positions among segments in the same workout' do
    segment = workouts(:segmented).segments.build(position: 2)

    assert_not segment.valid?
    assert_includes segment.errors[:position], 'has already been taken'
  end

  test 'rejects positions already used by top-level exercises' do
    segment = workouts(:segmented).segments.build(position: 1)

    assert_not segment.valid?
    assert_includes segment.errors[:position], 'has already been taken'
  end

  test 'rejects duplicate positions among unsaved segments in the same workout' do
    workout = Workout.new(name: 'Invalid Segment Positions', score_type: :time)
    segment = workout.segments.build(position: 1)

    workout.segments.build(position: 1)

    assert_not segment.valid?
    assert_includes segment.errors[:position], 'has already been taken'
  end

  test 'rejects top-level exercise positions already used by segments' do
    exercise = workouts(:segmented).exercises.build(movement: movements(:run), position: 2)

    assert_not exercise.valid?
    assert_includes exercise.errors[:position], 'has already been taken'
  end
end
