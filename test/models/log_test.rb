require 'test_helper'

class LogTest < ActiveSupport::TestCase
  test 'builds one movement recording per set for set-based lifting workouts' do
    log = workouts(:back_squat_5x5).logs.build(user: users(:mathew), score_type: :weight)
    log.build_movement_logs

    assert_equal 5, log.movement_logs.size

    log.movement_logs.each do |movement_log|
      assert_equal movements(:back_squat), movement_log.movement
      assert_equal 5, movement_log.reps
      assert_nil movement_log.load
      assert_not movement_log.records_load?
    end
  end

  test 'parses duration score values before score type assignment' do
    log = Log.new(workout: workouts(:fran), user: users(:mathew), score_value: '5:30', score_type: :time)

    assert_equal 330, log.score_value
  end

  test 'builds timed round movement recordings with per-round prescribed reps' do
    workout = workouts(:back_squat_5x5)
    workout.update!(score_type: :rep)

    log = workout.logs.build(user: users(:mathew), score_type: :rep)
    log.build_movement_logs

    assert_equal 1, log.movement_logs.size
    assert_equal 5, log.movement_logs.first.reps
  end

  test 'records per-round prescribed reps for segment exercises' do
    exercises(:segmented_hspu).update!(reps: 10)

    log = workouts(:segmented).logs.build(user: users(:mathew), score_type: :time)
    log.build_movement_logs

    hspu_log = log.movement_logs.find { |movement_log| movement_log.movement == movements(:hspu) }

    assert_equal 10, hspu_log.reps
  end

  test 'builds movement logs from direct column prescriptions' do
    workout = Workout.new(name: 'Direct Column Prescription', score_type: :time)
    segment = workout.segments.build(position: 1)
    segment.exercises.build(movement: movements(:back_squat), position: 1,
                            reps: 21, female_load: 65, male_load: 95, load_unit: :lb)
    workout.save!

    log = workout.logs.build(user: users(:mathew), score_type: :time, score_value: 180)
    log.build_movement_logs

    movement_log = log.movement_logs.first

    assert_equal 21, movement_log.reps
    assert_equal 95, movement_log.load
    assert_predicate movement_log, :records_load?
  end

  test 'calculates set-based lifting score from heaviest successful set' do
    log = workouts(:back_squat_5x5).logs.build(user: users(:mathew), score_type: :weight)
    log.build_movement_logs

    [95, 115, 135, 145, 155].each.with_index do |load, index|
      log.movement_logs[index].load = load
    end
    log.movement_logs[4].reps = 2

    assert log.valid?
    assert_equal 'lb', log.score_type
    assert_equal 145, log.score_value
  end

  test 'calculates single max-finding score from a successful logged load' do
    workout = Workout.create!(name: 'Back Squat Max', score_type: :weight)
    segment = workout.segments.create!(position: 1)
    segment.exercises.create!(movement: movements(:back_squat), position: 1, reps: 4,
                              duration_seconds: 240, load_unit: :lb)
    log = workout.logs.build(user: users(:mathew), score_type: :weight)
    log.build_movement_logs

    assert_equal 1, log.movement_logs.size
    assert_equal 4, log.movement_logs.first.reps
    assert_nil log.movement_logs.first.duration_seconds

    log.movement_logs.first.load = 405

    assert log.valid?
    assert_equal 'lb', log.score_type
    assert_equal 405, log.score_value
  end

  test 'does not calculate single max-finding score without completed prescribed reps' do
    workout = Workout.create!(name: 'Back Squat Max', score_type: :weight)
    segment = workout.segments.create!(position: 1)
    segment.exercises.create!(movement: movements(:back_squat), position: 1, reps: 4,
                              duration_seconds: 240, load_unit: :lb)
    log = workout.logs.build(user: users(:mathew), score_type: :weight)
    log.build_movement_logs
    log.movement_logs.first.assign_attributes(reps: 3, load: 405)

    assert log.valid?
    assert_nil log.score_value
  end
end
