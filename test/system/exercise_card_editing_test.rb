require 'application_system_test_case'

class ExerciseCardEditingTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test 'edits an existing workout exercise through a summary card' do
    visit edit_workout_url(workouts(:fran))

    within first('.exercise') do
      assert_no_field 'Reps'
      assert_text 'Thruster (95 weights)'

      click_on 'Thruster (95 weights)'

      assert_no_text 'Thruster (95 weights)'
      assert_field 'Reps', with: ''
      fill_in 'Reps', with: '15'
      click_on 'Save Exercise'

      assert_no_field 'Reps'
      assert_text '15 Thrusters'
    end
  end

  test 'edits a segment exercise through a summary card' do
    visit new_workout_url

    click_on 'Add Segment'

    within all('#workout-parts > .fields > .nested-fields').last do
      click_on 'Add Exercise'

      within '.exercise' do
        assert_field 'Position', with: '1'
        find('.ts-control input').set('Run')
        find('.ts-dropdown .option', text: 'Run').click
        fill_in 'Distance', with: '400', exact: true
        select 'meter', from: 'Distance unit'
        click_on 'Save Exercise'

        assert_no_field 'Distance'
        assert_text '400 meter Run'

        click_on '400 meter Run'
        assert_no_text '400 meter Run'
        assert_field 'Distance', with: '400'
      end
    end
  end

  test 'opening another card saves and collapses the currently open exercise' do
    visit edit_workout_url(workouts(:fran))

    cards = all('.exercise')

    within cards.first do
      click_on 'Thruster (95 weights)'
      fill_in 'Reps', with: '15'
    end

    within cards[1] do
      click_on 'Pull Up'
      assert_field 'Reps', with: ''
    end

    within cards.first do
      assert_no_field 'Reps'
      assert_text '15 Thrusters'
    end
  end

  test 'opening another card is blocked when the current exercise cannot be saved' do
    visit new_workout_url

    click_on 'Add Exercise'

    within first('.exercise') do
      find('.ts-control input').set('Pull')
      find('.ts-dropdown .option', text: 'Pull Up').click
      click_on 'Save Exercise'
      assert_text 'Pull Up'
    end

    click_on 'Add Exercise'

    within first('.exercise') do
      click_on 'Pull Up'
      assert_no_field 'Reps'
    end

    within all('.exercise').last do
      assert_field 'Reps'
      assert_text 'Select a movement'
    end
  end
end
