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
    assert_hidden_position all('#workout-parts > .fields > .exercise').last, '1'

    click_on 'Add Segment'
    within all('#workout-parts > .fields > .nested-fields').last do
      assert_equal '2', find('input[name$="[position]"]', visible: false).value

      click_on 'Add Exercise'
      assert_hidden_position all('.exercise').last, '1'

      click_on 'Add Exercise'
      positions = all('.exercise input[name$="[position]"]', visible: false).map(&:value)
      assert_equal %w[1 2], positions, "expected 2 exercises positions, got #{positions.inspect}"

      within all('.exercise').last do
        click_on 'Delete Exercise'
      end
      assert_equal 1, all('.exercise').size
    end

    within '#workout-parts > .links' do
      click_on 'Add Exercise'
    end
    assert_equal %w[1 3], all(
      '#workout-parts > .fields > .exercise input[name$="[position]"]',
      visible: false
    ).map(&:value)
  end

  test 'normalizes positions after removed workout parts' do
    visit new_workout_url

    click_on 'Add Exercise'
    assert_hidden_position all('#workout-parts > .fields > .exercise').last, '1'

    click_on 'Add Segment'
    within all('#workout-parts > .fields > .nested-fields').last do
      assert_equal '2', find('input[name$="[position]"]', visible: false).value
    end

    within '#workout-parts > .links' do
      click_on 'Add Exercise'
    end
    assert_hidden_position all('#workout-parts > .fields > .exercise').last, '3'

    find('[aria-label="Delete segment"]').click

    within '#workout-parts > .links' do
      click_on 'Add Exercise'
    end
    assert_equal %w[1 2 3], all(
      '#workout-parts > .fields > .exercise:not([hidden]) input[name$="[position]"]',
      visible: false
    ).map(&:value)
  end

  private

  def assert_hidden_position(scope, value)
    assert_equal value, scope.find('input[name$="[position]"]', visible: false).value
  end
end
