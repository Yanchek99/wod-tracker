require 'application_system_test_case'

class WorkoutSegmentPositionsTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test 'assigns exercise positions within each workout segment' do
    visit new_workout_url

    click_on 'Add Exercise'
    within '.top-level-exercises' do
      assert_field 'Position', with: '1'
    end

    click_on 'Add Segment'
    within all('.segments > .fields > .nested-fields').last do
      click_on 'Add Exercise'
      assert_field 'Position', with: '1'

      click_on 'Add Exercise'
      assert_equal %w[1 2], all('.exercise input[name$="[position]"]').map(&:value)
    end

    within '.top-level-exercises' do
      click_on 'Add Exercise'
      assert_equal %w[1 2], all('.exercise input[name$="[position]"]').map(&:value)
    end
  end
end
