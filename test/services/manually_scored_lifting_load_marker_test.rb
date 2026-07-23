require 'test_helper'

class ManuallyScoredLiftingLoadMarkerTest < ActiveSupport::TestCase
  test 'marks named load-bearing exercises in manually scored weight workouts' do
    exercise = build_exercise(movement: movements(:deadlift))

    ManuallyScoredLiftingLoadMarker.call(exercise.segment.workout)

    assert_equal 0, exercise.load
  end

  test 'uses raw-line fallback when scraper text carries the load-bearing cue' do
    exercise = build_exercise(movement: Movement.new(name: 'Walking Lunge'))
    exercise_line = { exercise: exercise, raw_line: '100-ft. front-rack walking lunge' }

    ManuallyScoredLiftingLoadMarker.call(exercise.segment.workout, exercise_lines: [exercise_line])

    assert_equal 0, exercise.load
  end

  test 'does not use scraper-only raw-line cues when none are supplied' do
    exercise = build_exercise(movement: Movement.new(name: 'Walking Lunge'))

    ManuallyScoredLiftingLoadMarker.call(exercise.segment.workout)

    assert_nil exercise.load
  end

  test 'does not overwrite existing load prescriptions' do
    exercise = build_exercise(movement: movements(:deadlift), female_load: 155, male_load: 225)

    ManuallyScoredLiftingLoadMarker.call(exercise.segment.workout)

    assert_nil exercise.load
    assert_equal [155, 225], [exercise.female_load, exercise.male_load]
  end

  test 'does not convert the workout into a calculated lifting score workout' do
    exercise = build_exercise(movement: movements(:deadlift), reps: 1, duration_seconds: 60)

    ManuallyScoredLiftingLoadMarker.call(exercise.segment.workout)

    assert_nil exercise.load
    assert_not exercise.segment.workout.calculated_lifting_score?
  end

  private

  def build_exercise(attrs = {})
    workout = Workout.new(name: 'Manual Load Test', score_type: :weight)
    segment = workout.segments.build(position: 1)
    segment.exercises.build({ movement: movements(:deadlift), position: 1, reps: 1 }.merge(attrs))
  end
end
