require 'test_helper'

class PersonalRecordsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:mathew)
  end

  test 'index redirects to the weightlifting family' do
    get user_personal_records_url(users(:mathew))

    assert_redirected_to family_user_personal_records_url(users(:mathew), family: 'weightlifting')
  end

  test 'an invalid family 404s' do
    get "/users/#{users(:mathew).id}/personal_records/not-a-family"

    assert_response :not_found
  end

  test 'gymnastics renders every distinct rep-count record for a movement' do
    pullup = movements(:pullup)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: pullup, duration_seconds: 60, reps: 20)
    log.movement_logs.create!(movement: pullup, duration_seconds: 120, reps: 35)

    get family_user_personal_records_url(users(:mathew), family: 'gymnastics')

    assert_response :success
    assert_select '.fw-semibold', text: 'Pull Up', count: 2
  end

  test 'gymnastics shows an empty state when the user has no gymnastics PRs' do
    get family_user_personal_records_url(users(:mathew), family: 'gymnastics')

    assert_response :success
    assert_select 'p', text: 'No gymnastics records yet.'
  end

  test 'gymnastics excludes movements from other families' do
    back_squat = movements(:back_squat)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: back_squat, load: 315, reps: 1)

    get family_user_personal_records_url(users(:mathew), family: 'gymnastics')

    assert_response :success
    assert_select '.fw-semibold', text: 'Back Squat', count: 0
  end

  test 'monostructural renders a movement log from its performance columns' do
    row = movements(:row)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: row, distance: 5000, distance_unit: :meter, duration_seconds: 1200)

    get family_user_personal_records_url(users(:mathew), family: 'monostructural')

    assert_response :success
    assert_select '.fw-semibold', text: 'Row', count: 1
  end

  test 'monostructural renders a bare distance/duration record without stray parens' do
    row = movements(:row)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: row, distance: 5000, distance_unit: :meter, duration_seconds: 1200)

    get family_user_personal_records_url(users(:mathew), family: 'monostructural')

    assert_response :success
    assert_select 'a', text: '5000 meters'
  end

  test 'monostructural excludes movements from other families' do
    pullup = movements(:pullup)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: pullup, reps: 5)

    get family_user_personal_records_url(users(:mathew), family: 'monostructural')

    assert_response :success
    assert_select '.fw-semibold', text: 'Pull Up', count: 0
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

  test 'subnav links to every family tab and repeated workouts' do
    get family_user_personal_records_url(users(:mathew), family: 'weightlifting')

    assert_select 'a[href=?]', family_user_personal_records_path(users(:mathew), family: 'gymnastics')
    assert_select 'a[href=?]', family_user_personal_records_path(users(:mathew), family: 'monostructural')
    assert_select 'a[href=?]', repeated_workouts_user_personal_records_path(users(:mathew))
  end
end
