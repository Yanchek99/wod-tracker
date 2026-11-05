require 'test_helper'

class SchedulesHelperTest < ActionView::TestCase
  include MetricsHelper

  test 'logged_result_msg drops the empty hours and leading zero from a short time' do
    assert_equal '5:00', logged_result_msg(Log.new(workout: workouts(:fran), score_type: :time, score_value: 300))
    assert_equal '12:30', logged_result_msg(Log.new(workout: workouts(:fran), score_type: :time, score_value: 750))
  end

  test 'logged_result_msg keeps the hours of a long time' do
    assert_equal '01:05:00', logged_result_msg(Log.new(workout: workouts(:murph), score_type: :time, score_value: 3900))
  end

  test 'logged_result_msg says Logged for an unscored result and leaves other scores alone' do
    assert_equal 'Logged', logged_result_msg(Log.new(workout: workouts(:fran), score_type: :time, score_value: nil))
    assert_equal '8 + 2 (202 reps)', logged_result_msg(logs(:matt_amrap))
  end
end
