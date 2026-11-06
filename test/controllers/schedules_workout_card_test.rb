require 'test_helper'

class SchedulesWorkoutCardTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:mathew)
  end

  test 'index renders the same workout card as the workout page, with a plain time cap and no chips' do
    workouts(:murph).update!(time_cap_seconds: 600)
    Schedule.create!(program: programs(:crossfit), workout: workouts(:murph),
                     posted_at: ActiveSupport::TimeZone['America/Los_Angeles'].local(2026, 8, 10, 18))

    get schedules_url

    assert_select '.workout-card .workout-name', text: 'Murph'
    assert_select '.workout-card .workout-objective'
    assert_select '.workout-card .workout-time-cap', text: /Time cap\s*10:00/
    assert_select '.workout-card .chips', count: 0
    assert_select '.workout-card [aria-label="Edit"]', count: 0
    assert_select '.workout-card .workout-posted', count: 0
  end

  test 'index lays out each day like the workout page, with Notes and Intended stimulus as side panels' do
    workouts(:murph).update!(notes: 'Scale the run.', intended_stimulus_notes: 'Steady pace.')
    Schedule.create!(program: programs(:crossfit), workout: workouts(:murph),
                     posted_at: ActiveSupport::TimeZone['America/Los_Angeles'].local(2026, 8, 10, 18))

    get schedules_url

    assert_select '.workout-show > .workout-show-main .workout-card'
    assert_select '.workout-show > .workout-show-side .workout-notes', text: /Scale the run\./
    assert_select '.workout-show > .workout-show-side .workout-stimulus', text: /Steady pace\./
    assert_select '.workout-card .workout-inline-notes', count: 0
  end

  test 'a day with several workouts shows numbered tabs and only the selected workout' do
    two_workouts_on_one_day

    get schedules_url

    assert_select '.schedule-tabs a', count: 2
    assert_select '.schedule-tabs a[aria-current="page"]', text: '1'
    assert_select '.workout-card .workout-name', count: 1
    assert_select '.workout-card .workout-name', text: 'Murph'
    assert_select '.workout-log-button', count: 1
  end

  test 'the workout param picks the tab and the tab links keep it in the URL' do
    two_workouts_on_one_day

    get schedules_url(workout: 2)

    assert_select '.schedule-tabs a[aria-current="page"]', text: '2'
    assert_select '.workout-card .workout-name', text: 'Fran'
    assert_select ".schedule-tabs a[href*='workout=1']", text: '1'
  end

  test 'the default tab is the first workout not yet logged' do
    two_workouts_on_one_day
    Log.create!(user: users(:mathew), workout: workouts(:murph), score_type: 'time', score_value: 3000)

    get schedules_url

    assert_select '.schedule-tabs a[aria-current="page"]', text: '2'
    assert_select '.workout-card .workout-name', text: 'Fran'
  end

  test 'the default tab is the first when every workout is logged, and a bad param falls back to the default' do
    two_workouts_on_one_day
    [workouts(:murph), workouts(:fran)].each do |w|
      Log.create!(user: users(:mathew), workout: w, score_type: 'time', score_value: 3000)
    end

    get schedules_url(workout: 9)

    assert_select '.schedule-tabs a[aria-current="page"]', text: '1'
  end

  test 'the day navigation drops the workout param so a new day picks its own default tab' do
    two_workouts_on_one_day
    Schedule.create!(program: programs(:crossfit), workout: workouts(:fran),
                     posted_at: ActiveSupport::TimeZone['America/Los_Angeles'].local(2026, 8, 11, 18))

    get schedules_url(workout: 2, date: '2026-08-11')

    assert_select '.schedule-stepper a[href*="workout"]', count: 0
  end

  test 'a day with one workout has no tabs' do
    Schedule.create!(program: programs(:crossfit), workout: workouts(:murph),
                     posted_at: ActiveSupport::TimeZone['America/Los_Angeles'].local(2026, 8, 10, 18))

    get schedules_url

    assert_select '.schedule-tabs', count: 0
    assert_select '.week-summary', count: 0
  end

  private

  def two_workouts_on_one_day
    users(:mathew).logs.where(workout: [workouts(:murph), workouts(:fran)]).destroy_all
    posted_at = ActiveSupport::TimeZone['America/Los_Angeles'].local(2026, 8, 10, 18)
    Schedule.create!(program: programs(:crossfit), workout: workouts(:murph), posted_at: posted_at)
    Schedule.create!(program: programs(:crossfit), workout: workouts(:fran), posted_at: posted_at)
  end
end
