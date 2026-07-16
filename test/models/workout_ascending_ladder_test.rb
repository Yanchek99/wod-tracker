require 'test_helper'

class WorkoutAscendingLadderTest < ActiveSupport::TestCase
  def ladder_workout(step: 3)
    Workout.new(name: 'Ladder', score_type: :rep, time: 7, ladder_step: step)
  end

  test 'ascending_ladder? follows the workout step' do
    assert_predicate ladder_workout, :ascending_ladder?
    assert_not Workout.new.ascending_ladder?
  end

  test 'a ladder workout is not treated as a fixed-rep amrap' do
    workout = ladder_workout
    segment = workout.segments.build(position: 1)
    segment.exercises.build(movement: movements(:thruster), position: 1, reps: 3)

    assert_not workout.fixed_rep_amrap?
    assert_nil workout.amrap_reps_per_round
  end

  test 'an exercise rides the ladder from its own reps as the round-1 start' do
    workout = ladder_workout
    segment = workout.segments.build(position: 1)
    exercise = segment.exercises.build(workout:, movement: movements(:thruster), position: 1, reps: 3)

    assert_predicate exercise, :ladder_participant?
    reps = (1..4).map { |round| exercise.ladder_reps(round) }
    assert_equal [3, 6, 9, 12], reps
  end

  test 'ladder_step_every holds the reps for several rounds before incrementing' do
    workout = ladder_workout
    segment = workout.segments.build(position: 1)
    exercise = segment.exercises.build(workout:, movement: movements(:thruster), position: 1, reps: 3, ladder_step_every: 3)

    reps = (1..7).map { |round| exercise.ladder_reps(round) }
    assert_equal [3, 3, 3, 6, 6, 6, 9], reps
  end

  test 'a ladder-exempt exercise stays constant' do
    workout = ladder_workout
    segment = workout.segments.build(position: 1)
    exercise = segment.exercises.build(workout:, movement: movements(:run), position: 1, reps: 10, ladder_exempt: true)

    assert_not exercise.ladder_participant?
    assert_nil exercise.ladder_reps(1)
  end

  test 'the ladder step is part of the content fingerprint' do
    by_three = ladder_workout(step: 3)
    by_three_segment = by_three.segments.build(position: 1)
    by_three_segment.exercises.build(movement: movements(:thruster), position: 1, reps: 3)
    by_six = ladder_workout(step: 6)
    by_six_segment = by_six.segments.build(position: 1)
    by_six_segment.exercises.build(movement: movements(:thruster), position: 1, reps: 3)

    assert_not_equal by_three.content_fingerprint, by_six.content_fingerprint
  end
end
