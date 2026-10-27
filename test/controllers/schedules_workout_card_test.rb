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
end
