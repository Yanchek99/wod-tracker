require 'test_helper'

class MeasurableHelperTest < ActionView::TestCase
  include MetricsHelper

  test 'does not render blank load metrics in workout prescriptions' do
    assert_equal '5 Back Squats', measurable_message(exercises(:back_squat_5x5_back_squat))
  end

  test 'renders sex-specific additional exercise metrics' do
    exercise = exercises(:fran_pullup)
    exercise.metrics.create!(measurement: :lb, female_value: 65, male_value: 95)

    assert_equal 'Pull Up / ♀ 65-lb / ♂ 95-lb', measurable_message(exercise)
  end
end
