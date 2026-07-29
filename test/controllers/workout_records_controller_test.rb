require 'test_helper'

class WorkoutRecordsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:mathew)
  end

  test 'index shows the best score per workout, one row per workout' do
    workout = workouts(:fran)
    users(:mathew).logs.create!(workout: workout, score_type: :time, score_value: 400)
    fast = users(:mathew).logs.create!(workout: workout, score_type: :time, score_value: 330)

    get user_workout_records_url(users(:mathew))

    assert_response :success
    assert_select 'th', text: 'Fran', count: 1
    assert_select 'a[href=?]', log_path(fast)
  end

  test 'index excludes a workout logged only once' do
    get user_workout_records_url(users(:mathew))

    assert_response :success
    assert_select 'th', text: 'Murph', count: 0
  end
end
