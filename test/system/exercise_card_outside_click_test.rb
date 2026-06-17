require 'application_system_test_case'

class ExerciseCardOutsideClickTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test 'clicking outside saves and collapses the currently open exercise' do
    visit edit_workout_url(workouts(:fran))

    within first('.exercise') do
      click_on 'Thruster (95 lbs)'
      fill_in 'Reps', with: '15'
    end

    find_field('Name').click

    within first('.exercise') do
      assert_no_field 'Reps'
      assert_text '15 Thrusters'
    end
  end

  test 'clicking outside is blocked when the current exercise cannot be saved' do
    visit new_workout_url

    click_on 'Add Exercise'
    find_field('Name').click

    within first('.exercise') do
      assert_field 'Reps'
      assert_text 'Select a movement'
    end
  end
end
