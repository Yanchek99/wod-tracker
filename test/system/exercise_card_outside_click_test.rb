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
    # Fran's persisted segment starts collapsed -- expand it to reach its exercises.
    find('.segment-summary__button').click

    within first('.exercise') do
      click_on 'Thruster (95 lbs)'
      fill_in 'Reps', with: '15'
    end

    # Clicking the workout's Name field is also outside the segment card, which
    # collapses it too (segment-card#handleDocumentClick) -- expand it again to
    # confirm the exercise itself saved and collapsed correctly.
    find_by_id('workout_name').click
    find('.segment-summary__button').click

    within first('.exercise') do
      assert_no_field 'Reps'
      assert_text '15 Thrusters'
    end
  end

  test 'clicking outside is blocked when the current exercise cannot be saved' do
    visit new_manual_workouts_url

    click_on 'Add Exercise'
    find_field('Name').click

    within first('.exercise') do
      assert_field 'Reps'
      assert_text 'Select a movement'
    end
  end
end
