require 'application_system_test_case'

class WorkoutSortableCardInputsTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test 'allows typing into fields inside sortable cards' do
    visit new_workout_url

    fill_in 'Name', with: 'Typed Card Fields'
    select 'time', from: 'For'
    click_on 'Add Segment'

    segment = all('#workout-parts > .fields > .nested-fields').last
    within segment do
      name_input = find_field('Name')
      name_input.click
      name_input.send_keys('Typed Segment')
      assert_equal 'Typed Segment', name_input.value

      click_on 'Add Exercise'
      reps_input = all('.exercise').last.find_field('Reps')
      reps_input.click
      reps_input.send_keys('12')
      assert_equal '12', reps_input.value
    end
  end

  test 'collapses existing segment cards and updates their summaries' do
    visit edit_workout_url(workouts(:segmented))

    segment = find('#workout-parts > .fields > .workout-part[data-controller~="segment-card"]')
    within segment do
      assert_text '10 rounds of'
      assert_selector '.workout-sortable-handle'
      assert_no_field 'Rounds'

      find('.segment-summary__button').click
      fill_in 'Rounds', with: '3'
      click_on 'Done'

      assert_text '3 rounds of'
      assert_no_field 'Rounds'
    end
  end

  test 'shows segment drag handles only while collapsed' do
    visit new_workout_url

    fill_in 'Name', with: 'Segment Handles'
    select 'time', from: 'For'
    click_on 'Add Segment'

    segment = all('#workout-parts > .fields > .workout-part[data-controller~="segment-card"]').last
    within segment do
      assert_no_selector '.workout-sortable-handle'

      click_on 'Done'

      assert_selector '.workout-sortable-handle'
    end
  end
end
