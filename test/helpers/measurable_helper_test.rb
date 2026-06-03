require 'test_helper'

class MeasurableHelperTest < ActionView::TestCase
  include MetricsHelper

  test 'does not render blank load metrics in workout prescriptions' do
    assert_equal '5 Back Squats', measurable_message(exercises(:back_squat_5x5_back_squat))
  end
end
