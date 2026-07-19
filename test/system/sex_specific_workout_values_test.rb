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

    fill_in 'Name *', with: 'Sex Specific System Test Workout'
    select 'time', from: 'For'
    # Filling the workout's own Name/For fields collapses the default segment
    # (segment-card#handleDocumentClick fires on any click outside its card).
    click_on 'New segment'
    click_on 'Add Exercise'

    within '.exercise' do
      find('.ts-control input').set('Thruster')
      find('.ts-dropdown .option', text: 'Thruster').click

      fill_in 'Reps', with: '1'
      fill_in 'Female load (lb)', with: '65'
      fill_in 'Male load (lb)', with: '95'
      click_on 'Done'
      assert_text 'Thruster (♀65lb / ♂95lb)'
      assert_no_field 'Female load'
    end

    click_on 'Save Workout'

    assert_current_path %r{/workouts/\d+}
    assert_text 'Sex Specific System Test Workout'
    assert_text 'Thruster (♀65lb / ♂95lb)'
  end
end
