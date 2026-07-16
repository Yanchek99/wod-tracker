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

    fill_in 'Name *', with: 'Inline Card Toolbars'
    select 'time', from: 'For'
    # Filling the workout's own Name/For fields collapses the default segment
    # (segment-card#handleDocumentClick fires on any click outside its card).
    click_on 'New segment'
    click_on 'Add Exercise'

    within all('.exercise').last do
      within '.workout-card-toolbar' do
        assert_button 'Done'
        assert_no_link 'Delete Exercise'
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

    fill_in 'Name *', with: 'Inline Exercise Movement Row'
    select 'time', from: 'For'
    # Filling the workout's own Name/For fields collapses the default segment
    # (segment-card#handleDocumentClick fires on any click outside its card).
    click_on 'New segment'
    click_on 'Add Exercise'

    within all('.exercise').last do
      within '.exercise-editor__movement-row' do
        assert_no_selector '[aria-label="Drag exercise"]'
        assert_field 'Movement'
        assert_selector '[aria-label="Delete exercise"]'
      end
    end
  end
end
