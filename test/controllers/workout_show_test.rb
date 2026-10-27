require 'test_helper'

class WorkoutShowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @workout = workouts(:fran)
    @user = users(:mathew)
    sign_in @user
  end

  test 'the card carries the workout name and objective' do
    get workout_url(@workout)

    assert_select '.workout-card h1', text: 'Fran'
    assert_select '.workout-card .workout-objective', text: '21-15-9 for time'
  end

  test 'shows the posted date and only shows edited when the workout was updated' do
    get workout_url(@workout)
    assert_select '.workout-posted', text: /Posted/
    assert_select '.workout-posted', text: /Edited/, count: 0

    travel_to(2.days.from_now) { @workout.update!(time_cap_seconds: 300) }
    get workout_url(@workout)
    assert_select '.workout-posted', text: /Edited/
  end

  test 'has no chips and shows a time cap as a plain line only when set' do
    get workout_url(@workout)
    assert_select '.chip', count: 0
    assert_select '.workout-time-cap', count: 0

    @workout.update!(time_cap_seconds: 600)
    get workout_url(@workout)
    assert_select '.workout-time-cap', text: /Time cap\s*10:00/
  end

  test 'links Log workout under the card' do
    get workout_url(@workout)

    assert_select "a.workout-log-button[href='#{new_workout_log_path(@workout)}']", text: 'Log workout'
  end

  test 'name row has labelled Schedule and Edit icon buttons' do
    get workout_url(@workout)

    assert_select ".workout-card [aria-label='Schedule'][data-bs-target='#scheduleModal']"
    assert_select ".workout-card a[aria-label='Edit'][href='#{edit_workout_path(@workout)}']"
    assert_select '#scheduleModal'
  end

  test 'a workout with nothing extra renders no empty panels' do
    get workout_url(@workout)

    assert_select '.workout-notes', count: 0
    assert_select '.workout-stimulus', count: 0
    assert_select '.workout-results', count: 0
  end

  test 'shows notes in their own panel when present' do
    @workout.update!(notes: 'Unbroken thrusters if you can.')
    get workout_url(@workout)

    assert_select '.workout-notes', text: /Unbroken thrusters if you can\./
    assert_select '.workout-card .notes', count: 0
  end

  test 'the collapsed Notes preview is plain text without markup' do
    @workout.update!(notes: '<div>Unbroken <strong>thrusters</strong> if you can.</div>')
    get workout_url(@workout)

    assert_select '.workout-notes .workout-collapsible-preview', text: 'Unbroken thrusters if you can.'
  end

  test 'shows the intended stimulus panel when a range is present' do
    @workout.update!(intended_stimulus_notes: 'Fast and unbroken.')
    get workout_url(@workout)

    assert_select '.workout-stimulus', text: /Fast and unbroken\./
  end

  test 'results rows link to each log, newest first, with a PR on the best' do
    older = log_for(score_value: 240, created_at: 3.days.ago)
    best = log_for(score_value: 200, created_at: 2.days.ago)
    newest = log_for(score_value: 260, created_at: 1.day.ago)

    get workout_url(@workout)

    rows = css_select('.workout-results a.workout-result')
    assert_equal [newest, best, older].map { |log| log_path(log) }, rows.pluck('href')
    assert_select '.chip-pr', count: 1
    assert_select ".workout-results a[href='#{log_path(best)}'] .chip-pr"
  end

  test 'a single log shows no PR chip' do
    log_for(score_value: 240, created_at: 1.day.ago)

    get workout_url(@workout)

    assert_select '.workout-results a.workout-result', count: 1
    assert_select '.chip-pr', count: 0
  end

  test 'a log without a score reads Logged' do
    log_for(score_value: nil, created_at: 1.day.ago)

    get workout_url(@workout)

    assert_select '.workout-result', text: /Logged/
  end

  private

  def log_for(score_value:, created_at:)
    Log.create!(workout: @workout, user: @user, score_type: :time, score_value: score_value, created_at: created_at)
  end
end
