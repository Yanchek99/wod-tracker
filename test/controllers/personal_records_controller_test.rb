require 'test_helper'

class PersonalRecordsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:mathew)
  end

  test 'index redirects to lifts' do
    get user_personal_records_url(users(:mathew))

    assert_redirected_to lifts_user_personal_records_url(users(:mathew))
  end

  test 'lifts renders every distinct rep-count record for a movement' do
    deadlift = movements(:deadlift)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: deadlift, load: 275, reps: 5)
    log.movement_logs.create!(movement: deadlift, load: 185, reps: 52)

    get lifts_user_personal_records_url(users(:mathew))

    assert_response :success
    assert_select 'th', text: 'Deadlift', count: 2
  end

  test 'lifts orders a movement\'s records by ascending rep count' do
    deadlift = movements(:deadlift)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: deadlift, load: 185, reps: 52)
    log.movement_logs.create!(movement: deadlift, load: 275, reps: 5)

    get lifts_user_personal_records_url(users(:mathew))

    assert_response :success
    load_values = response.body.scan(/(\d+) lbs/).flatten.map(&:to_i)
    heavy_load_index = load_values.index(275)
    light_load_index = load_values.index(185)
    assert_operator heavy_load_index, :<, light_load_index
  end

  test 'repeated_workouts shows the best score per workout, one row per workout' do
    workout = workouts(:fran)
    users(:mathew).logs.create!(workout: workout, score_type: :time, score_value: 400)
    fast = users(:mathew).logs.create!(workout: workout, score_type: :time, score_value: 330)

    get repeated_workouts_user_personal_records_url(users(:mathew))

    assert_response :success
    assert_select 'th', text: 'Fran', count: 1
    assert_select 'a[href=?]', log_path(fast)
  end

  test 'repeated_workouts excludes a workout logged only once' do
    get repeated_workouts_user_personal_records_url(users(:mathew))

    assert_response :success
    assert_select 'th', text: 'Murph', count: 0
  end
end
