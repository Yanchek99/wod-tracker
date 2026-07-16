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

    fill_in 'Name *', with: 'Typed Card Fields'
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

    # `segmented` now has 3 segments (segmented_before, test, segmented_after) --
    # scope to the schemed "test" one specifically by its exercise content.
    segment = find('#workout-parts > .fields > .workout-part[data-controller~="segment-card"]', text: 'Handstand Push Up')
    within segment do
      assert_text '10 rounds of'
      assert_text 'Handstand Push Up'
      assert_text 'Pistol'
      assert_equal ['Handstand Push Up', 'Pistol'], all('.segment-summary__detail').map(&:text)
      assert_selector '.workout-sortable-handle'
      assert_no_field 'Rounds'

      find('.segment-summary__button').click
      fill_in 'Rounds', with: '3'
      click_on 'Done'

      assert_text '3 rounds of'
      assert_no_field 'Rounds'
    end
  end

  test 'preserves max reps segment summaries after expanding and collapsing' do
    visit edit_workout_url(workouts(:segmented_total_reps))

    # `segmented_total_reps` now has 2 timed-block segments -- scope to the first one.
    segment = find('#workout-parts > .fields > .workout-part[data-controller~="segment-card"]', text: '0:00-5:00')
    within segment do
      assert_text '0:00-5:00: max reps in 5 minutes'

      find('.segment-summary__button').click
      assert_field 'Time seconds', with: '300'
      click_on 'Done'

      assert_text '0:00-5:00: max reps in 5 minutes'
      assert_no_text 'As many rounds as possible in 5 minutes'
    end
  end

  test 'shows segment drag handles only while collapsed' do
    visit new_workout_url

    fill_in 'Name *', with: 'Segment Handles'
    select 'time', from: 'For'
    click_on 'Add Segment'

    segment = all('#workout-parts > .fields > .workout-part[data-controller~="segment-card"]').last
    within segment do
      assert_no_selector '.workout-sortable-handle'

      click_on 'Done'

      assert_selector '.workout-sortable-handle'
    end
  end

  test 'shows nested exercise summaries when a segment collapses' do
    visit new_workout_url

    fill_in 'Name *', with: 'Segment Exercise Summaries'
    select 'time', from: 'For'
    click_on 'Add Segment'

    segment = all('#workout-parts > .fields > .workout-part[data-controller~="segment-card"]').last
    within segment do
      click_on 'Add Exercise'
      within all('.exercise').last do
        find('.ts-control input').set('Pull')
        find('.ts-dropdown .option', text: 'Pull Up').click
        fill_in 'Reps', with: '12'
        click_on 'Done'
      end

      click_on 'Done'

      within '.segment-summary' do
        assert_text '12 Pull Ups'
        assert_equal ['12 Pull Ups'], all('.segment-summary__detail').map(&:text)
      end
    end
  end

  test 'collapses an open segment when clicking outside it' do
    visit edit_workout_url(workouts(:segmented))

    # `segmented` now has 3 segments (segmented_before, test, segmented_after) --
    # scope to the schemed "test" one specifically by its exercise content.
    segment = find('#workout-parts > .fields > .workout-part[data-controller~="segment-card"]', text: 'Handstand Push Up')
    within segment do
      find('.segment-summary__button').click
      assert_field 'Rounds'
    end

    find_by_id('workout_name').click

    within segment do
      assert_no_field 'Rounds'
      assert_text '10 rounds of'
    end
  end
end
