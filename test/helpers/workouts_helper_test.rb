require 'test_helper'

class WorkoutsHelperTest < ActionView::TestCase
  test 'renders one round for time workouts as for time' do
    workout = Workout.new(name: 'Murph', score_type: :time)
    workout.segments.build(position: 1)

    assert_equal 'For Time', workout_objective(workout)
  end

  test 'renders a segment-less workout with a generic fallback objective' do
    workout = Workout.new(name: 'Empty Workout', score_type: :time)

    assert_equal 'For time', workout_objective(workout)
  end

  test 'renders set-based lifting workouts as sets for load' do
    workout = Workout.new(name: 'Back Squat 5x5', score_type: :weight)
    segment = workout.segments.build(rounds: 5, position: 1)
    segment.exercises.build(movement: movements(:back_squat), position: 1, reps: 5, load: 0)

    assert_equal '5 sets for load', workout_objective(workout)
  end

  test 'renders weight-scored rounds as sets for load without a prescribed load' do
    workout = Workout.create!(name: 'Back Squat 5x5', score_type: :weight)
    segment = workout.segments.create!(rounds: 5, position: 1)
    segment.exercises.create!(movement: movements(:back_squat), position: 1, reps: 5, load: 0)

    workout.exercises.each { |exercise| exercise.update!(load: nil, load_unit: nil, female_load: nil, male_load: nil) }

    assert_equal '5 sets for load', workout_objective(workout.reload)
  end

  test 'renders timed max-finding workouts as max load clocks' do
    workout = Workout.new(name: 'Back Squat Max', score_type: :weight)
    segment = workout.segments.build(position: 1)
    segment.exercises.build(movement: movements(:back_squat), position: 1, reps: 4,
                            duration_seconds: 240, load_unit: :lb)
    workout.valid? # canonicalizes load_unit into the load: 0 find-a-max sentinel

    assert_equal 'For load', workout_objective(workout)
  end

  test 'renders fixed-rep amraps as rounds and reps' do
    workout = Workout.new(name: 'AMRAP Couplet', score_type: :rep)
    segment = workout.segments.build(time_seconds: 600, position: 1)
    segment.exercises.build(movement: movements(:pullup), position: 1, reps: 10)
    segment.exercises.build(movement: movements(:pushup), position: 2, reps: 15)

    assert_equal 'As many rounds and reps as possible in 10 minutes', workout_objective(workout)
  end

  test 'renders segmented rep-scored clocks as total reps' do
    workout = Workout.new(name: 'Segmented Total Reps', score_type: :rep)

    first = workout.segments.build(time_seconds: 600, position: 1)
    first.exercises.build(movement: movements(:run), position: 1, reps: 1, distance: 200, distance_unit: :meter)

    second = workout.segments.build(time_seconds: 600, position: 2)
    second.exercises.build(movement: movements(:pushup), position: 1, reps: 0)

    assert_equal 'On a 20-minute clock for total reps', workout_objective(workout)
  end

  test 'renders segmented rep-scored clocks from segment windows' do
    workout = Workout.new(name: 'Windowed Reps', score_type: :rep)

    first = workout.segments.build(time_seconds: 300, position: 1)
    first.exercises.build(movement: movements(:run), position: 1, reps: 1, distance: 200, distance_unit: :meter)
    first.exercises.build(movement: movements(:pushup), position: 2, reps: 0)

    second = workout.segments.build(time_seconds: 300, position: 2)
    second.exercises.build(movement: movements(:run), position: 1, reps: 1, distance: 200, distance_unit: :meter)
    second.exercises.build(movement: movements(:pullup), position: 2, reps: 0)

    assert_equal 'On a 10-minute clock for total reps', workout_objective(workout)
  end

  test 'renders timed rep-scored rounds as round amraps' do
    workout = Workout.new(name: 'Back Squat 5x5', score_type: :rep)
    segment = workout.segments.build(rounds: 5, time_seconds: 180, position: 1)
    segment.exercises.build(movement: movements(:back_squat), position: 1, reps: 5, load: 0)

    assert_equal '5 rounds, complete as many reps as possible in 3 minutes of', workout_objective(workout)
  end

  test 'renders time-capped ascending ladders' do
    workout = Workout.new(score_type: :rep, ladder_step: 3)
    workout.segments.build(time_seconds: 420, position: 1)

    assert_equal 'As many reps as possible in 7 minutes, ascending ladder, +3 reps each round',
                 workout_objective(workout)
  end

  test 'renders cap-less ascending ladders' do
    workout = Workout.new(score_type: :rep, ladder_step: 2)

    assert_equal 'Ascending ladder, +2 reps each round', workout_objective(workout)
  end

  test 'has no team descriptor for an individual workout' do
    assert_nil team_objective(Workout.new(score_type: :time))
  end

  test 'renders a two-athlete workout as partner' do
    assert_equal 'Partner', team_objective(Workout.new(score_type: :time, team_size: 2))
  end

  test 'renders a larger team workout as team of n' do
    assert_equal 'Team of 4', team_objective(Workout.new(score_type: :time, team_size: 4))
  end
end
