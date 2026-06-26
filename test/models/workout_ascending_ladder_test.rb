require 'test_helper'

class WorkoutAscendingLadderTest < ActiveSupport::TestCase
  def ladder_workout(start: 3, step: 3)
    Workout.new(name: 'Ladder', score_type: :rep, time: 7, ladder_start: start, ladder_step: step)
  end

  test 'ascending_ladder? requires both a start and a step' do
    assert_predicate ladder_workout, :ascending_ladder?
    assert_not Workout.new(ladder_start: 3).ascending_ladder?
    assert_not Workout.new(ladder_step: 3).ascending_ladder?
    assert_not Workout.new.ascending_ladder?
  end

  test 'rejects a half-specified ladder' do
    workout = Workout.new(name: 'Half', score_type: :rep, ladder_start: 3)

    assert_not workout.valid?
    assert(workout.errors[:base].any? { |message| message.include?('ascending ladder') })
  end

  test 'a blank-rep exercise rides the ladder' do
    exercise = ladder_workout.exercises.build(movement: movements(:thruster), position: 1)

    assert_predicate exercise, :ladder_participant?
    reps = (1..4).map { |round| exercise.ladder_reps(round) }
    assert_equal [3, 6, 9, 12], reps
  end

  test 'ladder_step_every holds the reps for several rounds before incrementing' do
    exercise = ladder_workout.exercises.build(movement: movements(:thruster), position: 1, ladder_step_every: 3)

    reps = (1..7).map { |round| exercise.ladder_reps(round) }
    assert_equal [3, 3, 3, 6, 6, 6, 9], reps
  end

  test 'a fixed-rep exercise stays off the ladder' do
    exercise = ladder_workout.exercises.build(movement: movements(:run), position: 1, reps: 10)

    assert_not exercise.ladder_participant?
    assert_nil exercise.ladder_reps(1)
  end

  test 'the ladder step is part of the content fingerprint' do
    by_three = ladder_workout(step: 3)
    by_three.exercises.build(movement: movements(:thruster), position: 1)
    by_six = ladder_workout(step: 6)
    by_six.exercises.build(movement: movements(:thruster), position: 1)

    assert_not_equal by_three.content_fingerprint, by_six.content_fingerprint
  end
end
