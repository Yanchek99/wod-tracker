require 'test_helper'

class WorkoutsHelperTest < ActionView::TestCase
  test 'renders one round for time workouts as for time' do
    assert_equal 'For Time', workout_objective(workouts(:murph))
  end

  test 'renders set-based lifting workouts as sets for load' do
    assert_equal '5 sets for load', workout_objective(workouts(:back_squat_5x5))
  end
end
