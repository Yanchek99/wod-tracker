require 'test_helper'

class SchedulesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:mathew)
  end

  test 'index batches logged workout lookup for rendered schedules' do
    Schedule.create!(
      program: programs(:crossfit),
      workout: workouts(:murph),
      posted_at: schedules(:one).posted_at
    )

    query_counts = count_matching_queries(logs: /FROM "logs"/, exercises: /FROM "exercises"/) do
      get schedules_url
    end

    assert_response :success
    assert_equal 1, query_counts[:logs]
    assert_equal 1, query_counts[:exercises]
  end

  test 'index date heading renders the scheduled calendar day without browser-local conversion' do
    create_schedule_on('2026-08-10')

    get schedules_url

    assert_response :success
    assert_select 'h3', text: /August 10, 2026/
    assert_select 'h3 time[data-local]', count: 0
  end

  test 'index with date param jumps to the exact scheduled date' do
    create_schedule_on('2026-08-01')
    create_schedule_on('2026-08-10')
    create_schedule_on('2026-08-20')

    get schedules_url(date: '2026-08-10')

    assert_response :success
    assert_select 'h3', text: /August 10, 2026/
  end

  test 'index with date param snaps to the nearest earlier scheduled date' do
    create_schedule_on('2026-08-01')
    create_schedule_on('2026-08-20')

    get schedules_url(date: '2026-08-15')

    assert_response :success
    assert_select 'h3', text: /August\s+1, 2026/
  end

  test 'index with date param before all schedules clamps to the earliest date' do
    Schedule.delete_all
    create_schedule_on('2026-08-01')
    create_schedule_on('2026-08-20')

    get schedules_url(date: '2020-01-01')

    assert_response :success
    assert_select 'h3', text: /August\s+1, 2026/
  end

  test 'index with date param after all schedules clamps to the most recent date' do
    create_schedule_on('2026-08-01')
    create_schedule_on('2026-08-20')

    get schedules_url(date: '2027-01-01')

    assert_response :success
    assert_select 'h3', text: /August 20, 2026/
  end

  private

  # Mirrors ScrapeCfWodJob#posted_at_for, which anchors every real CF.com schedule to 6pm
  # America/Los_Angeles -- an instant that falls after UTC midnight, so tests must anchor the
  # same way rather than at UTC midnight to actually exercise the controller's date handling.
  def create_schedule_on(date)
    parsed = Date.parse(date)
    Schedule.create!(
      program: programs(:crossfit),
      workout: workouts(:murph),
      posted_at: ActiveSupport::TimeZone['America/Los_Angeles'].local(parsed.year, parsed.month, parsed.day, 18)
    )
  end

  def count_matching_queries(patterns, &)
    counts = patterns.transform_values { 0 }
    callback = lambda do |_name, _started, _finished, _unique_id, payload|
      next if payload[:cached] || payload[:name] == 'SCHEMA'

      patterns.each { |name, pattern| counts[name] += 1 if payload[:sql].match?(pattern) }
    end

    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record', &)

    counts
  end
end
