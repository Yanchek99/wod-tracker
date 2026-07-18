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
    # Fran's persisted segment starts collapsed -- expand it to reach its exercises.
    find('.segment-summary__button').click

    within first('.exercise') do
      assert_no_field 'Reps'
      assert_text 'Thruster (95 lbs)'

      click_on 'Thruster (95 lbs)'

      assert_no_text 'Thruster (95 lbs)'
      assert_field 'Reps', with: '1'
      fill_in 'Reps', with: '15'
      click_on 'Done'

      assert_no_field 'Reps'
      assert_text '15 Thrusters'
    end
  end

  test 'edits a segment exercise through a summary card' do
    visit new_manual_workouts_url

    click_on 'Add Segment'

    within all('#workout-parts > .fields > .nested-fields').last do
      click_on 'Add Exercise'

      within '.exercise' do
        assert_equal '1', find('input[name$="[position]"]', visible: false).value
        find('.ts-control input').set('Run')
        find('.ts-dropdown .option', text: 'Run').click
        fill_in 'Distance', with: '400', exact: true
        select 'meter', from: 'Distance unit'
        click_on 'Done'

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
    # Fran's persisted segment starts collapsed -- expand it to reach its exercises.
    find('.segment-summary__button').click

    cards = all('.exercise')

    within cards.first do
      click_on 'Thruster (95 lbs)'
      fill_in 'Reps', with: '15'
    end

    within cards[1] do
      click_on 'Pull Up'
      assert_field 'Reps', with: '1'
    end

    within cards.first do
      assert_no_field 'Reps'
      assert_text '15 Thrusters'
    end
  end

  test 'shows the implements field only for dumbbell and kettlebell movements' do
    Movement.create!(name: 'Dumbbell Thruster')
    visit new_manual_workouts_url

    click_on 'Add Exercise'

    within first('.exercise') do
      assert_no_field 'Implements'

      find('.ts-control input').set('Pull')
      find('.ts-dropdown .option', text: 'Pull Up').click
      assert_no_field 'Implements'

      find('.ts-control input').set('Dumbbell')
      find('.ts-dropdown .option', text: 'Dumbbell Thruster').click
      assert_field 'Implements'
    end
  end

  test 'opening another card is blocked when the current exercise cannot be saved' do
    visit new_manual_workouts_url

    click_on 'Add Exercise'

    within first('.exercise') do
      find('.ts-control input').set('Pull')
      find('.ts-dropdown .option', text: 'Pull Up').click
      click_on 'Done'
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
