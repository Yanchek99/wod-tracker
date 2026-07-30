require 'test_helper'

class LiftingLoadSentinelMarkerTest < ActiveSupport::TestCase
  test 'marks named load-bearing exercises in manually scored weight workouts' do
    exercise = build_exercise(movement: movements(:deadlift))

    LiftingLoadSentinelMarker.call(exercise.segment.workout)

    assert_equal 0, exercise.load
  end

  test 'uses raw-line fallback when scraper text carries the load-bearing cue' do
    exercise = build_exercise(movement: Movement.new(name: 'Walking Lunge'))
    exercise_line = { exercise: exercise, raw_line: '100-ft. front-rack walking lunge' }

    LiftingLoadSentinelMarker.call(exercise.segment.workout, exercise_lines: [exercise_line])

    assert_equal 0, exercise.load
  end

  test 'does not use scraper-only raw-line cues when none are supplied' do
    exercise = build_exercise(movement: Movement.new(name: 'Walking Lunge'))

    LiftingLoadSentinelMarker.call(exercise.segment.workout)

    assert_nil exercise.load
  end

  test 'does not overwrite existing load prescriptions' do
    exercise = build_exercise(movement: movements(:deadlift), female_load: 155, male_load: 225)

    LiftingLoadSentinelMarker.call(exercise.segment.workout)

    assert_nil exercise.load
    assert_equal [155, 225], [exercise.female_load, exercise.male_load]
  end

  test 'does not convert the workout into a calculated lifting score workout' do
    exercise = build_exercise(movement: movements(:deadlift), reps: 1, duration_seconds: 60)

    LiftingLoadSentinelMarker.call(exercise.segment.workout)

    assert_nil exercise.load
    assert_not exercise.segment.workout.calculated_lifting_score?
  end

  test 'marks load-bearing sets in a calculated set-based lifting workout' do
    workout = build_lifting_sets(movement: movements(:deadlift), reps: [10, 10, 7, 7, 3, 3, 3])

    LiftingLoadSentinelMarker.call(workout)

    assert workout.set_based_lifting?
    assert_equal [0, 0, 0, 0, 0, 0, 0], workout.segments.first.exercises.map(&:load)
  end

  private

  def build_lifting_sets(movement:, reps:)
    workout = Workout.new(name: 'Set-Based Lift Test', score_type: :weight)
    segment = workout.segments.build(position: 1)
    reps.each_with_index do |set_reps, index|
      segment.exercises.build(movement: movement, position: index + 1, reps: set_reps)
    end
    workout
  end

  def build_exercise(attrs = {})
    workout = Workout.new(name: 'Manual Load Test', score_type: :weight)
    segment = workout.segments.build(position: 1)
    segment.exercises.build({ movement: movements(:deadlift), position: 1, reps: 1 }.merge(attrs))
  end
end
