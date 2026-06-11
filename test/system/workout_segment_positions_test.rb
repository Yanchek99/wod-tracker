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
    assert_field 'Position', with: '1'

    click_on 'Add Segment'
    within all('#workout-parts > .fields > .nested-fields').last do
      assert_field 'Position', with: '2'

      click_on 'Add Exercise'
      assert_field 'Position', with: '1'

      click_on 'Add Exercise'
      positions = all('.exercise input[name$="[position]"]').map(&:value)
      assert_equal %w[1 2], positions, "expected 2 exercises positions, got #{positions.inspect}"
    end

    within '#workout-parts > .links' do
      click_on 'Add Exercise'
    end
    assert_equal %w[1 3], all('#workout-parts > .fields > .exercise input[name$="[position]"]').map(&:value)
  end

  test 'assigns positions past removed workout parts' do
    visit new_workout_url

    click_on 'Add Exercise'
    assert_field 'Position', with: '1'

    click_on 'Add Segment'
    within all('#workout-parts > .fields > .nested-fields').last do
      assert_field 'Position', with: '2'
    end

    within '#workout-parts > .links' do
      click_on 'Add Exercise'
    end
    assert_field 'Position', with: '3'

    click_on 'Delete Segment'

    within '#workout-parts > .links' do
      click_on 'Add Exercise'
    end
    assert_equal %w[1 3 4], all('#workout-parts > .fields > .exercise input[name$="[position]"]').map(&:value)
  end
end
