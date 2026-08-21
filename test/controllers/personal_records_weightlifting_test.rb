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
    log.movement_logs.create!(movement: back_squat, load: 275, reps: 3, set_breakdown: [3])

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

  test 'weightlifting labels a reps: 0 record "Max" instead of "0RM"' do
    back_squat = movements(:back_squat)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: back_squat, load: 145, reps: 0)

    get family_user_personal_records_url(users(:mathew), family: 'weightlifting')

    assert_response :success
    assert_select '.fw-semibold', text: 'Back Squat', count: 1
    assert_select 'a', text: '145 lbs'
    assert_match(/Max/, response.body)
    assert_no_match(/0RM/, response.body)
  end

  test 'weightlifting labels a reps: 0 row "Max" alongside labeled rep-max rows in the expanded list' do
    front_squat = movements(:front_squat)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: front_squat, load: 255, reps: 1)
    log.movement_logs.create!(movement: front_squat, load: 145, reps: 0)

    get family_user_personal_records_url(users(:mathew), family: 'weightlifting')

    assert_response :success
    assert_select '[data-rep-max-row-target="details"]' do
      assert_select 'span', text: 'Max'
      assert_select 'span', text: '1RM'
    end
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

  test 'weightlifting excludes a reps>1 record with no captured set breakdown' do
    back_squat = movements(:back_squat)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: back_squat, load: 225, reps: 21)

    get family_user_personal_records_url(users(:mathew), family: 'weightlifting')

    assert_response :success
    assert_select '.fw-semibold', text: 'Back Squat', count: 0
  end

  test 'weightlifting labels a captured set breakdown by its largest verified unbroken set, not the raw total' do
    back_squat = movements(:back_squat)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: back_squat, load: 225, reps: 45, set_breakdown: [21, 15, 9])

    get family_user_personal_records_url(users(:mathew), family: 'weightlifting')

    assert_response :success
    assert_select '.fw-semibold', text: 'Back Squat', count: 1
    assert_match(/21RM/, response.body)
    assert_no_match(/45RM/, response.body)
  end
end
