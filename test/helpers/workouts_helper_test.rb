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

  test 'renders fixed-rep amraps as rounds and reps' do
    assert_equal 'As many rounds and reps as possible in 10 minutes', workout_objective(workouts(:amrap_couplet))
  end

  test 'renders segmented rep-scored clocks as total reps' do
    assert_equal 'On a 20-minute clock for total reps', workout_objective(workouts(:segmented_total_reps))
  end

  test 'renders timed rep-scored rounds as round amraps' do
    workout = workouts(:back_squat_5x5)
    workout.update!(time: 3, score_type: :rep)

    assert_equal '5 rounds, complete as many reps as possible in 3 minutes of', workout_objective(workout)
  end

  test 'renders time-capped ascending ladders' do
    workout = Workout.new(score_type: :rep, time: 7, ladder_start: 3, ladder_step: 3)

    assert_equal 'As many reps as possible in 7 minutes, ascending ladder (3, 6, 9, …; +3 reps each round)',
                 workout_objective(workout)
  end

  test 'renders cap-less ascending ladders' do
    workout = Workout.new(score_type: :rep, ladder_start: 10, ladder_step: 2)

    assert_equal 'Ascending ladder (10, 12, 14, …; +2 reps each round)', workout_objective(workout)
  end
end
