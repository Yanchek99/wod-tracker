require 'test_helper'

class LogTest < ActiveSupport::TestCase
  test 'builds one movement recording per set for set-based lifting workouts' do
    log = workouts(:back_squat_5x5).logs.build(user: users(:mathew), score_type: :weight)
    log.build_movement_logs

    assert_equal 5, log.movement_logs.size

    log.movement_logs.each do |movement_log|
      assert_equal movements(:back_squat), movement_log.movement
      assert_equal 5, movement_log.metrics.find(&:rep?).value
      assert_nil movement_log.metrics.find(&:lb?).value
    end
  end

  test 'defaults sex-specific prescribed load values when building movement logs' do
    workout = Workout.new(rounds: 1, score_type: :time)
    workout.exercises.build(movement: movements(:back_squat), position: 1) do |exercise|
      exercise.metrics.build(measurement: :rep, value: 21)
      exercise.metrics.build(measurement: :lb, female_value: 65, male_value: 95)
    end

    log = workout.logs.build(user: users(:mathew), score_type: :time, score_value: 180)
    log.build_movement_logs

    lb_metric = log.movement_logs.first.metrics.find(&:lb?)

    assert_equal 95, lb_metric.value
    assert_equal 'lb', lb_metric.measurement
  end

  test 'parses duration score values before score type assignment' do
    log = Log.new(workout: workouts(:fran), user: users(:mathew), score_value: '5:30', score_type: :time)

    assert_equal 330, log.score_value
  end

  test 'builds timed round movement recordings with per-round prescribed reps' do
    workout = workouts(:back_squat_5x5)
    workout.update!(time: 3, score_type: :rep)

    log = workout.logs.build(user: users(:mathew), score_type: :rep)
    log.build_movement_logs

    assert_equal 1, log.movement_logs.size
    assert_equal 5, log.movement_logs.first.metrics.find(&:rep?).value
  end

  test 'calculates set-based lifting score from heaviest successful set' do
    log = workouts(:back_squat_5x5).logs.build(user: users(:mathew), score_type: :weight)
    log.build_movement_logs

    [95, 115, 135, 145, 155].each.with_index do |load, index|
      log.movement_logs[index].metrics.find(&:lb?).value = load
    end
    log.movement_logs[4].metrics.find(&:rep?).value = 2

    assert log.valid?
    assert_equal 'lb', log.score_type
    assert_equal 145, log.score_value
  end
end
