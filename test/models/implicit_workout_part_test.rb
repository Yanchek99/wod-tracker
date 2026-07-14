require 'test_helper'

class ImplicitWorkoutPartTest < ActiveSupport::TestCase
  test 'treats implicit segment exercises as former top-level exercises for scoring' do
    workout = workouts(:back_squat_5x5)
    exercise = exercises(:back_squat_5x5_back_squat)
    wrap_in_segment(workout, exercise, rounds: workout.rounds)

    assert_equal [exercise], workout.reload.top_level_exercises
    assert_predicate workout, :set_based_lifting?
  end

  test 'builds set-based lifting recordings from an implicit segment wrapper' do
    workout = workouts(:back_squat_5x5)
    exercise = exercises(:back_squat_5x5_back_squat)
    wrap_in_segment(workout, exercise, rounds: workout.rounds)

    log = workout.reload.logs.build(user: users(:mathew), score_type: :weight)
    log.build_movement_logs

    assert_equal 5, log.movement_logs.size
    assert_equal [movements(:back_squat)] * 5, log.movement_logs.map(&:movement)
  end

  test 'calculates single max-finding score from an implicit segment wrapper' do
    workout = Workout.create!(name: 'Back Squat Max', score_type: :weight)
    exercise = workout.exercises.create!(movement: movements(:back_squat), position: 1, reps: 4,
                                         duration_seconds: 240, load: 0)
    wrap_in_segment(workout, exercise)

    log = workout.reload.logs.build(user: users(:mathew), score_type: :weight)
    log.build_movement_logs
    log.movement_logs.first.load = 405

    assert log.valid?
    assert_equal 'lb', log.score_type
    assert_equal 405, log.score_value
  end

  test 'calculates fixed amrap reps from an implicit segment wrapper' do
    workout = Workout.create!(name: 'Implicit AMRAP', score_type: :rep, time: 10)
    exercise = workout.exercises.create!(movement: movements(:pushup), position: 1, reps: 15)
    wrap_in_segment(workout, exercise, time_seconds: 600)

    assert_equal 15, workout.reload.amrap_reps_per_round
  end

  private

  def wrap_in_segment(workout, exercise, **attrs)
    segment = workout.segments.create!({ position: 2 }.merge(attrs))
    exercise.update!(segment:, position: 1)
    segment.update!(position: 1)
  end
end
