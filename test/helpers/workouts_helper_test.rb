require 'test_helper'

class WorkoutsHelperTest < ActionView::TestCase
  test 'renders set-based lifting workouts as sets for load' do
    assert_equal '5 sets for load', workout_objective(workouts(:back_squat_5x5))
  end
end
