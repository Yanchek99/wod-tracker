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
end
