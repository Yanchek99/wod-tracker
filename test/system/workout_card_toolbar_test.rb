require 'application_system_test_case'

class WorkoutCardToolbarTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test 'renders expanded card actions in inline toolbars' do
    visit new_workout_url

    fill_in 'Name', with: 'Inline Card Toolbars'
    select 'time', from: 'For'
    click_on 'Add Exercise'

    within all('#workout-parts > .fields > .exercise').last do
      within '.workout-card-toolbar' do
        assert_button 'Done'
        assert_link 'Delete Exercise'
      end
      assert_no_selector '.d-grid'
    end

    click_on 'Add Segment'

    segment = all('#workout-parts > .fields > .workout-part[data-controller~="segment-card"]').last
    within segment do
      assert_selector '.workout-card-toolbar', count: 1

      within '.links.workout-card-toolbar' do
        assert_link 'Add Exercise'
        assert_button 'Done'
        assert_link 'Delete Segment'
      end
      assert_no_selector '.d-grid'
    end
  end

  test 'renders expanded exercise movement row actions inline' do
    visit new_workout_url

    fill_in 'Name', with: 'Inline Exercise Movement Row'
    select 'time', from: 'For'
    click_on 'Add Exercise'

    within all('#workout-parts > .fields > .exercise').last do
      within '.exercise-editor__movement-row' do
        assert_selector '[aria-label="Drag exercise"]'
        assert_field 'Movement'
        assert_selector '[aria-label="Delete exercise"]'
      end
    end
  end

  test 'collapses an expanded exercise before dragging it' do
    visit new_workout_url

    fill_in 'Name', with: 'Collapse Exercise Before Drag'
    select 'time', from: 'For'
    click_on 'Add Exercise'

    exercise = all('#workout-parts > .fields > .exercise').last
    within exercise do
      find('.ts-control input').set('Pull')
      find('.ts-dropdown .option', text: 'Pull Up').click
      fill_in 'Reps', with: '10'
      assert_field 'Reps'
    end

    handle = exercise.find('.exercise-editor__handle')
    page.execute_script("arguments[0].dispatchEvent(new PointerEvent('pointerdown', { bubbles: true }))", handle)

    within exercise do
      assert_no_field 'Reps'
      assert_text '10 Pull Ups'
    end
  end
end
