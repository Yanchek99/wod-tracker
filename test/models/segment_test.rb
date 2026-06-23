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

  test 'identifies emom segments by whole-minute rounds' do
    assert_predicate Segment.new(time_seconds: 600, rounds: 10), :emom?
    assert_not_predicate Segment.new(time_seconds: 630, rounds: 10), :emom?
  end

  test 'identifies timed rounds segments' do
    assert_predicate Segment.new(time_seconds: 1500, rounds: 4), :timed_rounds?
    assert_not_predicate Segment.new(rounds: 4), :timed_rounds?
  end

  test 'identifies max-rep segments by zero-rep exercises' do
    segment = Segment.new(time_seconds: 300)
    segment.exercises.build(reps: 0)

    assert_predicate segment, :max_reps?
  end

  test 'identifies interval segments by their scheme' do
    assert_predicate Segment.new(interval_scheme: '21-15-9'), :interval?
    assert_not_predicate Segment.new, :interval?
  end

  test 'sums interval scheme reps' do
    assert_equal 45, Segment.new(interval_scheme: '21-15-9').reps_from_interval
    assert_nil Segment.new.reps_from_interval
  end

  test 'parses duration strings into time seconds' do
    assert_equal 1200, Segment.new(time_seconds: '20:00').time_seconds
    assert_equal 3630, Segment.new(time_seconds: '1:00:30').time_seconds
    assert_equal 90, Segment.new(time_seconds: '90').time_seconds
    assert_equal 90, Segment.new(time_seconds: 90).time_seconds
  end
end
