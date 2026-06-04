require 'application_system_test_case'

class WorkoutWorkflowsTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test 'creates a workout with an exercise' do
    visit new_workout_url

    fill_in 'Name', with: 'System Test Workout'
    select 'time', from: 'For'
    click_on 'Add Exercise'

    within '.exercise' do
      assert_no_field 'Distance units per rep'
      find('.ts-control input').set('Pull')
      find('.ts-dropdown .option', text: 'Pull Up').click
      assert_no_selector '.ts-wrapper.dropdown-active'
      assert_field 'Position', with: '1'
      click_on 'Add Metric'
      find('input[name$="[value]"]').set('10')
      find('select.metric', visible: :all).select('rep')
      assert_no_field 'Distance units per rep'
    end

    click_on 'Create Workout'

    assert_current_path %r{/workouts/\d+}
    assert_text 'Workout was successfully created.'
    assert_text 'System Test Workout'
    assert_text '10 Pull Ups'
  end

  test 'shows distance units per rep only for distance metrics' do
    visit new_workout_url

    fill_in 'Name', with: 'Distance Scored Workout'
    select 'rep', from: 'For'
    click_on 'Add Exercise'

    within '.exercise' do
      assert_no_field 'Distance units per rep'

      click_on 'Add Metric'
      find('input[name$="[value]"]').set('400')
      find('select.metric', visible: :all).select('meter')

      assert_field 'Distance units per rep'
    end
  end

  test 'filters workouts through the turbo frame search' do
    visit workouts_url

    fill_in 'Search workout name', with: 'Murph'

    assert_selector "#workout_#{workouts(:murph).id}", text: 'Murph'
    assert_no_selector "#workout_#{workouts(:fran).id}"
  end

  test 'schedules a workout' do
    subscriptions(:one).update!(role: :owner)
    visit workout_url(workouts(:murph))

    find('[data-bs-target="#scheduleModal"]').click

    within '#scheduleModal' do
      select 'Crossfit', from: 'Program'
      click_on 'Add to Schedule'
    end

    assert_text 'Schedule was successfully created.'
    visit schedules_url
    assert_text 'Murph'
  end

  test 'logs a workout result' do
    visit workout_url(workouts(:fran))

    click_on 'Log'
    fill_in 'log_metric_attributes_value', with: '5:30'
    click_on 'Save'

    assert_current_path %r{/logs/\d+}
    assert_text 'Log was successfully created.'
    assert_text 'Fran'
    assert_text '00:05:30'
  end

  test 'logs an amrap with rounds plus reps without changing movement recordings' do
    visit workout_url(workouts(:amrap_mixed))

    click_on 'Log'

    assert_equal %w[300 10 20], amrap_recording_values

    fill_in 'log_metric_attributes_value', with: '1+35'

    assert_equal %w[300 10 20], amrap_recording_values

    click_on 'Save'

    assert_current_path %r{/logs/\d+}
    assert_text '1 + 35 (95 reps)'
    assert_text '300 meters'
    assert_text '10 Push Ups'
    assert_text '20 calories'
  end

  private

  def amrap_recording_values
    all('.card.mb-3').map do |movement_log|
      movement_log.find('input[name$="[value]"]').value
    end
  end
end
