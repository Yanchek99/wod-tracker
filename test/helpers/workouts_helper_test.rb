require 'test_helper'

class WorkoutsHelperTest < ActionView::TestCase
  test 'renders one round for time workouts as for time' do
    assert_equal 'For Time', workout_objective(workouts(:murph))
  end

  test 'renders set-based lifting workouts as sets for load' do
    assert_equal '5 sets for load', workout_objective(workouts(:back_squat_5x5))
  end

  test 'renders weight-scored rounds as sets for load without a prescribed load' do
    workout = workouts(:back_squat_5x5)
    workout.exercises.each { |exercise| exercise.update!(load: nil, load_unit: nil, female_load: nil, male_load: nil) }

    assert_equal '5 sets for load', workout_objective(workout.reload)
  end

  test 'renders timed max-finding workouts as max load clocks' do
    workout = Workout.new(name: 'Back Squat Max', score_type: :weight)
    workout.exercises.build(movement: movements(:back_squat), position: 1, reps: 4,
                            duration_seconds: 240, load_unit: :lb)
    workout.valid? # canonicalizes load_unit into the load: 0 find-a-max sentinel

    assert_equal 'For load', workout_objective(workout)
  end

  test 'renders fixed-rep amraps as rounds and reps' do
    assert_equal 'As many rounds and reps as possible in 10 minutes', workout_objective(workouts(:amrap_couplet))
  end

  test 'renders segmented rep-scored clocks as total reps' do
    assert_equal 'On a 20-minute clock for total reps', workout_objective(workouts(:segmented_total_reps))
  end

  test 'renders segmented rep-scored clocks from segment windows' do
    workout = Workout.new(name: 'Windowed Reps', score_type: :rep)

    first = workout.segments.build(time_seconds: 300, position: 1)
    workout.exercises.build(movement: movements(:run), segment: first, position: 1,
                            reps: 1, distance: 200, distance_unit: :meter)
    workout.exercises.build(movement: movements(:pushup), segment: first, position: 2, reps: 0)

    second = workout.segments.build(time_seconds: 300, position: 2)
    workout.exercises.build(movement: movements(:run), segment: second, position: 1,
                            reps: 1, distance: 200, distance_unit: :meter)
    workout.exercises.build(movement: movements(:pullup), segment: second, position: 2, reps: 0)

    assert_equal 'On a 10-minute clock for total reps', workout_objective(workout)
  end

  test 'renders timed rep-scored rounds as round amraps' do
    workout = workouts(:back_squat_5x5)
    workout.update!(time: 3, score_type: :rep)

    assert_equal '5 rounds, complete as many reps as possible in 3 minutes of', workout_objective(workout)
  end

  test 'renders time-capped ascending ladders' do
    workout = Workout.new(score_type: :rep, time: 7, ladder_step: 3)

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
