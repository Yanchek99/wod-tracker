require 'test_helper'

class SchedulesIndexPageTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:mathew)
  end

  test 'index shows the header log action for a single scheduled workout' do
    create_schedule_on('2026-08-10')

    get schedules_url

    assert_select '.page-header a[href=?]', new_workout_log_path(workouts(:murph)), text: /Log workout/
    assert_select '.schedule-card a.schedule-log', count: 1
  end

  test 'index puts a log button on each card and none in the header when a day has several workouts' do
    create_schedule_on('2026-08-10')
    create_schedule_on('2026-08-10', workout: workouts(:fran))

    get schedules_url

    assert_select '.page-header a[href*="/logs/new"]', count: 0
    assert_select '.schedule-card a.schedule-log', count: 2
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
