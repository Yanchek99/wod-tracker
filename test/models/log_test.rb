require 'test_helper'

class LogTest < ActiveSupport::TestCase
  test 'normalizes rounds plus reps to total reps' do
    log = workouts(:amrap_couplet).logs.build(user: users(:mathew))
    log.build_metric(measurement: :rep, value: '20+2')

    assert log.valid?
    assert_equal 502, log.metric.value
    assert_equal 25, log.reps_per_round
  end

  test 'normalizes overflow reps into total reps' do
    log = workouts(:amrap_couplet).logs.build(user: users(:mathew))
    log.build_metric(measurement: :rep, value: '20+27')

    assert log.valid?
    assert_equal 527, log.metric.value
  end

  test 'normalizes rounds plus reps using submitted scaled movement recordings' do
    log = workouts(:amrap_couplet).logs.build(user: users(:mathew))
    log.build_metric(measurement: :rep, value: '20+2')
    log.build_movement_logs

    pushup_recording = log.movement_logs.find { |movement_log| movement_log.movement == movements(:pushup) }
    pushup_recording.metrics.find(&:rep?).value = 5

    assert log.valid?
    assert_equal 302, log.metric.value
    assert_equal 15, log.reps_per_round
  end

  test 'accepts raw total reps' do
    log = workouts(:amrap_couplet).logs.build(user: users(:mathew))
    log.build_metric(measurement: :rep, value: '202')

    assert log.valid?
    assert_equal 202, log.metric.value
    assert_equal 25, log.reps_per_round
  end

  test 'rejects malformed amrap score input' do
    log = workouts(:amrap_couplet).logs.build(user: users(:mathew))
    log.build_metric(measurement: :rep, value: '20.5')

    assert_not log.valid?
    assert_includes log.errors[:metric], 'score must be total reps or rounds plus reps'
  end

  test 'rejects negative amrap score input' do
    log = workouts(:amrap_couplet).logs.build(user: users(:mathew))
    log.build_metric(measurement: :rep, value: -1)

    assert_not log.valid?
    assert_includes log.errors[:metric], 'score must be total reps or rounds plus reps'
  end

  test 'rejects rounds plus reps when round size is unknown' do
    log = workouts(:amrap_unknown_distance).logs.build(user: users(:mathew))
    log.build_metric(measurement: :rep, value: '2+5')

    assert_not log.valid?
    assert_includes log.errors[:metric], 'rounds plus reps requires a fixed reps-per-round total'
  end

  test 'returns amrap score parts from snapshotted reps per round' do
    parts = logs(:matt_amrap).amrap_score_parts

    assert_equal({ rounds: 8, reps: 2, total: 202 }, parts)
  end

  test 'builds one movement recording per set for set-based lifting workouts' do
    log = workouts(:back_squat_5x5).logs.build(user: users(:mathew))
    log.build_metric(measurement: :weight)
    log.build_movement_logs

    assert_equal 5, log.movement_logs.size

    log.movement_logs.each do |movement_log|
      assert_equal movements(:back_squat), movement_log.movement
      assert_equal 5, movement_log.metrics.find(&:rep?).value
      assert_nil movement_log.metrics.find(&:lb?).value
    end
  end

  test 'calculates set-based lifting score from heaviest successful set' do
    log = workouts(:back_squat_5x5).logs.build(user: users(:mathew))
    log.build_metric(measurement: :weight)
    log.build_movement_logs

    [95, 115, 135, 145, 155].each.with_index do |load, index|
      log.movement_logs[index].metrics.find(&:lb?).value = load
    end
    log.movement_logs[4].metrics.find(&:rep?).value = 2

    assert log.valid?
    assert_equal 'lb', log.metric.measurement
    assert_equal 145, log.metric.value
  end
end
