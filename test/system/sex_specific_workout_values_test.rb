require 'application_system_test_case'

class SexSpecificWorkoutValuesTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test 'creates a workout with sex-specific exercise values' do
    visit new_workout_url

    fill_in 'Name', with: 'Sex Specific System Test Workout'
    select 'time', from: 'For'
    click_on 'Add Exercise'

    within '.exercise' do
      find('.ts-control input').set('Thruster')
      find('.ts-dropdown .option', text: 'Thruster').click

      click_on 'Add Metric'
      find('input[name$="[value]"]').set('1')
      find('select.metric', visible: :all).select('rep')

      click_on 'Add Metric'
      all('input[placeholder="Female value"]').last.set('65')
      all('input[placeholder="Male value"]').last.set('95')
      all('select.metric', visible: :all).last.select('lb')
    end

    click_on 'Create Workout'

    assert_current_path %r{/workouts/\d+}
    assert_text 'Sex Specific System Test Workout'
    assert_text 'Thruster (♀65lb / ♂95lb)'
  end
end
