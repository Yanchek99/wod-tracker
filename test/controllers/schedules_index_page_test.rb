require 'test_helper'

class SchedulesIndexPageTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:mathew)
  end

  test 'index puts the desktop log button under the workout card, not in the page header' do
    create_schedule_on('2026-08-10')

    get schedules_url

    assert_select '.page-header a[href*="/logs/new"]', count: 0
    assert_select '.workout-show-main > a.workout-log-button[href=?]', new_workout_log_path(workouts(:murph)), text: /Log workout/
    assert_select '.workout-card a', text: /Log workout/, count: 0
  end

  test 'index gives each workout its own log button under its card when a day has several workouts' do
    create_schedule_on('2026-08-10')
    create_schedule_on('2026-08-10', workout: workouts(:fran))

    get schedules_url

    assert_select '.page-header a[href*="/logs/new"]', count: 0
    assert_select '.workout-show-main > a.workout-log-button', count: 2
  end

  test 'index marks today with a chip only when showing the current calendar day' do
    create_schedule_on('2026-08-10')

    get schedules_url

    assert_select '.chip-today', count: 0

    create_schedule_on(ActiveSupport::TimeZone['America/Los_Angeles'].today.to_s)

    get schedules_url

    assert_select '.chip-today', text: 'Today'
  end

  test 'index shows a history panel only for workouts the user has logged' do
    create_schedule_on('2026-08-10')
    create_schedule_on('2026-08-11', workout: workouts(:fran))

    get schedules_url(date: '2026-08-10')

    assert_select '.workout-history', count: 1
    assert_select '.workout-history', text: /Times logged\s*1/

    get schedules_url(date: '2026-08-11')

    assert_select '.workout-history', count: 0
  end

  test 'index history panel shows best with a PR chip once a workout was logged twice' do
    create_schedule_on('2026-08-10')
    get schedules_url

    assert_select '.workout-history .chip-pr', count: 0

    Log.create!(user: users(:mathew), workout: workouts(:murph), score_type: 'time', score_value: 3000)

    get schedules_url

    assert_select '.workout-history .chip-pr', text: 'PR'
    assert_select '.workout-history', text: /Times logged\s*2/
  end

  test 'index renders an empty state when the user has no schedules' do
    Schedule.delete_all

    get schedules_url

    assert_response :success
    assert_select '.empty-state', text: /No schedules/
  end

  test 'index history panel says Logged for an unscored result and never crowns an unscored best' do
    create_schedule_on('2026-08-10')
    users(:mathew).logs.where(workout: workouts(:murph)).destroy_all
    2.times { Log.create!(user: users(:mathew), workout: workouts(:murph), score_type: 'time', score_value: nil) }

    get schedules_url

    assert_select '.workout-history', text: /Last result\s*Logged/
    assert_select '.workout-history', text: /1 time/, count: 0
    assert_select '.workout-history .chip-pr', count: 0
  end

  test 'index renders the page header as a full-width bar above the content with both day buttons' do
    create_schedule_on('2026-08-10')

    get schedules_url

    assert_select '.app-main > .page-header', count: 1
    assert_select '.app-main > main.app-content .page-header', count: 0
    assert_select '.schedule-stepper .btn-icon', count: 2
  end

  test 'index shows a this-week panel with logged and scheduled counts' do
    create_schedule_on('2026-08-10')
    create_schedule_on('2026-08-12', workout: workouts(:fran))
    users(:mathew).logs.where(workout: workouts(:murph)).destroy_all
    Log.create!(user: users(:mathew), workout: workouts(:murph), score_type: 'time', score_value: 3000,
                created_at: Time.zone.local(2026, 8, 10, 20))

    get schedules_url(date: '2026-08-10')

    assert_select '.week-summary', count: 1
    assert_select '.week-summary', text: /Workouts logged\s*1 of 2/
    assert_select '.week-summary', text: /New PRs\s*0/
  end

  test 'index keeps one logs query with the this-week panel across several days' do
    create_schedule_on('2026-08-10')
    create_schedule_on('2026-08-12', workout: workouts(:fran))
    queries = 0
    counter = ->(*, payload) { queries += 1 if !payload[:cached] && payload[:sql].match?(/FROM "logs"/) }

    ActiveSupport::Notifications.subscribed(counter, 'sql.active_record') { get schedules_url(date: '2026-08-10') }

    assert_equal 1, queries
  end

  private

  def create_schedule_on(date, workout: workouts(:murph))
    parsed = Date.parse(date)
    Schedule.create!(
      program: programs(:crossfit),
      workout: workout,
      posted_at: ActiveSupport::TimeZone['America/Los_Angeles'].local(parsed.year, parsed.month, parsed.day, 18)
    )
  end
end
