require_relative 'helper'

class CapabilityEstimatorTimedTest < ActiveSupport::TestCase
  include CapabilityEstimatorHelper

  setup do
    setup_estimator_user
    @run = movements(:run)
    @fran = workouts(:fran)
  end

  def rows = CapabilityEstimator::Timed.call(samples)

  test 'distance work with a duration becomes one row' do
    create_log(@fran, { movement: @run, distance: 1609, distance_unit: :meter, duration_seconds: 302 })

    row = rows.sole
    assert_equal [1609, 'meter', 302], [row[:distance], row[:distance_unit].to_s, row[:duration_seconds]]
    assert_nil row[:reps]
  end

  test 'reps with a distance setting keep both' do
    create_log(@fran, { movement: movements(:burpee), reps: 50, distance: 24, distance_unit: :inch, duration_seconds: 130 })

    row = rows.sole
    assert_equal [50, 24, 'inch', 130], [row[:reps], row[:distance], row[:distance_unit].to_s, row[:duration_seconds]]
  end

  test 'a log without a duration, or without reps and distance, yields nothing' do
    create_log(@fran, { movement: @run, distance: 400, distance_unit: :meter })
    create_log(@fran, { movement: @run, duration_seconds: 120 })

    assert_empty rows
  end

  test 'the fastest time for a setting wins and sample_count counts the logs' do
    create_log(@fran, { movement: @run, distance: 1609, distance_unit: :meter, duration_seconds: 320 })
    create_log(@fran, { movement: @run, distance: 1609, distance_unit: :meter, duration_seconds: 302 })

    row = rows.sole
    assert_equal [302, 2], [row[:duration_seconds], row[:sample_count]]
  end

  test 'different loads are different rows' do
    create_log(@fran, { movement: @run, reps: 10, load: 45, duration_seconds: 60 })
    create_log(@fran, { movement: @run, reps: 10, load: 65, duration_seconds: 80 })

    assert_equal 2, rows.size
  end

  test 'confidence is 0.5 with one log, 0.1 more per extra log, capped at 0.8' do
    create_log(@fran, { movement: @run, distance: 400, distance_unit: :meter, duration_seconds: 100 })
    assert_in_delta 0.5, rows.sole[:confidence]

    create_log(@fran, { movement: @run, distance: 400, distance_unit: :meter, duration_seconds: 99 })
    assert_in_delta 0.6, rows.sole[:confidence]

    5.times { create_log(@fran, { movement: @run, distance: 400, distance_unit: :meter, duration_seconds: 99 }) }
    assert_in_delta 0.8, rows.sole[:confidence]
  end

  test 'a reps 0 placeholder with a distance setting keeps only the usable setting' do
    create_log(@fran, { movement: movements(:burpee), reps: 0, distance: 24, distance_unit: :inch, duration_seconds: 60 })

    row = rows.sole
    assert_nil row[:reps]
    assert_equal [24, 'inch', 60], [row[:distance], row[:distance_unit].to_s, row[:duration_seconds]]
  end

  test 'a unitless distance with no reps is not a usable timed point' do
    create_log(@fran, { movement: @run, distance: 1600, distance_unit: nil, duration_seconds: 300 })

    assert_empty rows
  end

  test 'a duration copied from the exercise prescription is not the athlete result' do
    workout = Workout.new(name: 'Timed Cleans', score_type: :time)
    workout.segments.build(position: 1).exercises.build(movement: movements(:clean), position: 1, reps: 5, duration_seconds: 60)
    workout.save!
    create_log(workout, { movement: movements(:clean), reps: 5, duration_seconds: 60 })
    assert_empty rows

    create_log(workout, { movement: movements(:clean), reps: 5, duration_seconds: 45 })
    assert_equal [45], rows.pluck(:duration_seconds)
  end

  test 'a double-implement time is its own setting' do
    create_log(@fran, { movement: @run, reps: 10, load: 45, duration_seconds: 60 })
    create_log(@fran, { movement: @run, reps: 10, load: 45, implement_count: 2, duration_seconds: 80 })

    by_count = rows.index_by { |row| row[:implement_count] }
    assert_equal [60, 80], [by_count[nil][:duration_seconds], by_count[2][:duration_seconds]]
  end
end
