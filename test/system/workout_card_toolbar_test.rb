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
      within '.links.workout-card-toolbar' do
        assert_link 'Add Exercise'
      end

      within '.workout-card-toolbar:not(.links)' do
        assert_button 'Done'
        assert_link 'Delete Segment'
      end
      assert_no_selector '.d-grid'
    end
  end
end
