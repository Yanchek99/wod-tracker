require 'test_helper'

class WorkoutsHelperTest < ActionView::TestCase
  test 'renders one round for time workouts as for time' do
    assert_equal 'For Time', workout_objective(workouts(:murph))
  end

  test 'renders set-based lifting workouts as sets for load' do
    assert_equal '5 sets for load', workout_objective(workouts(:back_squat_5x5))
  end

  test 'renders fixed-rep amraps as rounds and reps' do
    assert_equal 'As many rounds and reps as possible in 10 minutes', workout_objective(workouts(:amrap_couplet))
  end

  test 'renders timed rep-scored rounds as round amraps' do
    workout = workouts(:back_squat_5x5)
    workout.update!(time: 3)
    workout.update!(score_type: :rep)

    assert_equal '5 rounds, complete as many reps as possible in 3 minutes of', workout_objective(workout)
  end
end
