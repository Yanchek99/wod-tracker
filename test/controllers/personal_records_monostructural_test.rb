require 'test_helper'

class PersonalRecordsMonostructuralTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:mathew)
  end

  test 'monostructural renders a movement log from its performance columns' do
    row = movements(:row)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: row, distance: 5000, distance_unit: :meter, duration_seconds: 1200)

    get family_user_personal_records_url(users(:mathew), family: 'monostructural')

    assert_response :success
    assert_select '.fw-semibold', text: 'Row', count: 1
  end

  test 'monostructural shows both the distance and the time for a bare distance/duration record' do
    row = movements(:row)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: row, distance: 5000, distance_unit: :meter, duration_seconds: 1200)

    get family_user_personal_records_url(users(:mathew), family: 'monostructural')

    assert_response :success
    assert_select '.text-muted', text: /5000m/
    assert_select 'a', text: '20:00'
  end

  test 'monostructural excludes movements from other families' do
    pullup = movements(:pullup)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: pullup, reps: 5)

    get family_user_personal_records_url(users(:mathew), family: 'monostructural')

    assert_response :success
    assert_select '.fw-semibold', text: 'Pull Up', count: 0
  end

  test 'monostructural groups a movement\'s distance/time PRs and headlines the most recently logged one' do
    row = movements(:row)
    older = users(:mathew).logs.create!(workout: workouts(:fran), score_type: :time, score_value: 1, created_at: 2.days.ago)
    newer = users(:mathew).logs.create!(workout: workouts(:fran), score_type: :time, score_value: 1, created_at: 1.day.ago)
    older.movement_logs.create!(movement: row, distance: 2000, distance_unit: :meter, duration_seconds: 500)
    newer.movement_logs.create!(movement: row, distance: 500, distance_unit: :meter, duration_seconds: 100)

    get family_user_personal_records_url(users(:mathew), family: 'monostructural')

    assert_response :success
    assert_select '.fw-semibold', text: 'Row', count: 1
    assert_select 'button .text-muted', text: /500m/
  end

  test 'monostructural expands to show every distance in ascending order, regardless of headline' do
    row = movements(:row)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: row, distance: 5000, distance_unit: :meter, duration_seconds: 1200)
    log.movement_logs.create!(movement: row, distance: 500, distance_unit: :meter, duration_seconds: 100)
    log.movement_logs.create!(movement: row, distance: 2000, distance_unit: :meter, duration_seconds: 500)

    get family_user_personal_records_url(users(:mathew), family: 'monostructural')

    assert_response :success
    details = response.parsed_body.at_css('[data-rep-max-row-target="details"]')
    distances = details.css('.d-flex').map { |row_element| row_element.at_css('span').text[/\d+/].to_i }
    assert_equal [500, 2000, 5000], distances
  end

  test 'monostructural shows no expand block for a movement with a single distance/time PR' do
    row = movements(:row)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: row, distance: 5000, distance_unit: :meter, duration_seconds: 1200)

    get family_user_personal_records_url(users(:mathew), family: 'monostructural')

    assert_response :success
    assert_select '[hidden]', count: 0
  end

  test 'monostructural keeps a non-distance/time record (e.g. calorie-based) in the flat list' do
    row = movements(:row)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: row, duration_seconds: 300, calories: 87)

    get family_user_personal_records_url(users(:mathew), family: 'monostructural')

    assert_response :success
    assert_select '[data-controller="rep-max-row"]', count: 0
    assert_select '.fw-semibold', text: 'Row', count: 1
  end

  test 'monostructural shows an empty state when the user has no monostructural PRs' do
    get family_user_personal_records_url(users(:mathew), family: 'monostructural')

    assert_response :success
    assert_select 'p', text: 'No monostructural records yet.'
  end
end
