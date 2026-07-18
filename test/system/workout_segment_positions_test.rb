require 'application_system_test_case'

class WorkoutSegmentPositionsTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    login_as users(:mathew), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test 'assigns exercise positions within a segment' do
    visit new_manual_workouts_url

    default_segment = all('#workout-parts > .fields > .workout-part').last
    within default_segment do
      click_on 'Add Exercise'
      assert_hidden_position all('.exercise').last, '1'

      click_on 'Add Exercise'
      positions = all('.exercise input[name$="[position]"]', visible: false).map(&:value)
      assert_equal %w[1 2], positions, "expected 2 exercise positions, got #{positions.inspect}"

      within all('.exercise').last do
        find('[aria-label="Delete exercise"]').click
      end
      assert_equal 1, all('.exercise').size
    end
  end

  test 'assigns sequential positions to segments as they are added' do
    visit new_manual_workouts_url

    default_segment = all('#workout-parts > .fields > .workout-part').last
    assert_segment_position default_segment, '1'

    click_on 'Add Segment'
    second_segment = all('#workout-parts > .fields > .workout-part').last
    assert_segment_position second_segment, '2'

    click_on 'Add Segment'
    third_segment = all('#workout-parts > .fields > .workout-part').last
    assert_segment_position third_segment, '3'
  end

  test 'normalizes segment positions after a segment is removed' do
    visit new_manual_workouts_url

    click_on 'Add Segment'
    click_on 'Add Segment'
    segments = all('#workout-parts > .fields > .workout-part')
    assert_equal(%w[1 2 3], segments.map { |segment| segment_position(segment) })

    within segments[1] do
      find('[aria-label="Delete segment"]').click
    end

    remaining = all('#workout-parts > .fields > .workout-part:not([hidden])')
    assert_equal(%w[1 2], remaining.map { |segment| segment_position(segment) })
  end

  private

  def assert_hidden_position(scope, value)
    assert_equal value, scope.find('input[name$="[position]"]', visible: false).value
  end

  # A `>` direct-child lookup, unlike assert_hidden_position: a segment's own hidden
  # position field must be distinguished from any exercise nested inside it, whose
  # position field also matches a bare `input[name$="[position]"]` descendant search.
  def assert_segment_position(scope, value)
    assert_equal value, segment_position(scope)
  end

  def segment_position(scope)
    scope.find(:css, ':scope > input[name$="[position]"]', visible: false).value
  end
end
