require 'test_helper'

class SchedulesHelperTest < ActionView::TestCase
  test 'workout_chips labels a time-scored workout and its time cap' do
    workout = Workout.new(name: 'Capped', score_type: :time, time_cap_seconds: 600)

    assert_equal ['For time', 'Time cap 10:00'], workout_chips(workout)
  end

  test 'workout_chips omits the time cap chip when there is none' do
    assert_equal ['For time'], workout_chips(Workout.new(name: 'Open', score_type: :time))
  end

  test 'workout_chips labels non-time scoring' do
    assert_equal ['Scored in reps'], workout_chips(Workout.new(name: 'Max reps', score_type: :rep))
  end
end
