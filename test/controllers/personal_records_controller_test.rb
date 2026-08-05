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

  test 'barbell groups a movement\'s rep-maxes and orders them by ascending reps' do
    back_squat = movements(:back_squat)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: back_squat, load: 315, reps: 1)
    log.movement_logs.create!(movement: back_squat, load: 275, reps: 3)

    get barbell_user_personal_records_url(users(:mathew))

    assert_response :success
    assert_select 'h2, h3, .fw-semibold', text: 'Back Squat', count: 1
    load_values = response.body.scan(/(\d+) lbs/).flatten.map(&:to_i)
    heavy_index = load_values.index(315)
    light_index = load_values.index(275)
    assert_operator heavy_index, :<, light_index
  end

  test 'barbell excludes non-weightlifting movements' do
    deadlift = movements(:deadlift) # fixture has no family set, so family_weightlifting? is false
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: deadlift, load: 405, reps: 1)

    get barbell_user_personal_records_url(users(:mathew))

    assert_response :success
    assert_select '.fw-semibold', text: 'Deadlift', count: 0
  end

  test 'barbell shows one PR without an expand block when a movement has a single rep-max' do
    back_squat = movements(:back_squat)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: back_squat, load: 315, reps: 1)

    get barbell_user_personal_records_url(users(:mathew))

    assert_response :success
    assert_select '.fw-semibold', text: 'Back Squat', count: 1
    assert_select '[hidden]', count: 0
  end

  test 'subnav links to the barbell tab' do
    get lifts_user_personal_records_url(users(:mathew))

    assert_select 'a[href=?]', barbell_user_personal_records_path(users(:mathew))
  end
end
