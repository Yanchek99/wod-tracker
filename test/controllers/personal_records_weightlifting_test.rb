require 'test_helper'

class PersonalRecordsWeightliftingTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:mathew)
  end

  test 'weightlifting groups a movement\'s rep-maxes and orders them by ascending reps' do
    back_squat = movements(:back_squat)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: back_squat, load: 315, reps: 1)
    log.movement_logs.create!(movement: back_squat, load: 275, reps: 3)

    get family_user_personal_records_url(users(:mathew), family: 'weightlifting')

    assert_response :success
    assert_select '.fw-semibold', text: 'Back Squat', count: 1
    load_values = response.body.scan(/(\d+) lbs/).flatten.map(&:to_i)
    heavy_index = load_values.index(315)
    light_index = load_values.index(275)
    assert_operator heavy_index, :<, light_index
  end

  test 'weightlifting excludes non-weightlifting movements' do
    deadlift = movements(:deadlift) # fixture has no family set, so family_weightlifting? is false
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: deadlift, load: 405, reps: 1)

    get family_user_personal_records_url(users(:mathew), family: 'weightlifting')

    assert_response :success
    assert_select '.fw-semibold', text: 'Deadlift', count: 0
  end

  test 'weightlifting shows one PR without an expand block when a movement has a single rep-max' do
    back_squat = movements(:back_squat)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: back_squat, load: 315, reps: 1)

    get family_user_personal_records_url(users(:mathew), family: 'weightlifting')

    assert_response :success
    assert_select '.fw-semibold', text: 'Back Squat', count: 1
    assert_select '[hidden]', count: 0
  end

  test 'weightlifting renders a loaded record with no rep count instead of a bare RM label' do
    back_squat = movements(:back_squat)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: back_squat, load: 405, reps: nil)

    get family_user_personal_records_url(users(:mathew), family: 'weightlifting')

    assert_response :success
    assert_select '.fw-semibold', text: 'Back Squat', count: 1
    assert_select 'a', text: '405 lbs'
    assert_no_match(/\bRM\b/, response.body)
  end

  test 'weightlifting renders a loaded record with reps: 0 instead of a "0RM" label' do
    back_squat = movements(:back_squat)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: back_squat, load: 145, reps: 0)

    get family_user_personal_records_url(users(:mathew), family: 'weightlifting')

    assert_response :success
    assert_select '.fw-semibold', text: 'Back Squat', count: 1
    assert_select 'a', text: '145 lbs'
    assert_no_match(/0RM/, response.body)
  end

  test 'weightlifting excludes a record with reps but no load' do
    back_squat = movements(:back_squat)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: back_squat, load: nil, reps: 12)

    get family_user_personal_records_url(users(:mathew), family: 'weightlifting')

    assert_response :success
    assert_select '.fw-semibold', text: 'Back Squat', count: 0
  end

  test 'weightlifting shows an empty state when the user has no weightlifting PRs' do
    get family_user_personal_records_url(users(:mathew), family: 'weightlifting')

    assert_response :success
    assert_select 'p', text: 'No weightlifting records yet.'
  end
end
