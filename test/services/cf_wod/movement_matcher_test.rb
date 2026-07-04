require 'test_helper'

module CfWod
  class MovementMatcherTest < ActiveSupport::TestCase
    test 'normalizes and matches existing catalog movements regardless of prose pluralization' do
      {
        'box jumps' => 'Box Jump',
        'wall-ball shots' => 'Wall-ball Shot',
        'thrusters' => 'Thruster',
        'power snatches' => 'Power Snatch',
        'push presses' => 'Push Press',
        'double-unders' => 'Double-under',
        'bent-over rows' => 'Bent-over Row'
      }.each do |prose, expected|
        result = MovementMatcher.match(prose)

        assert_not result.ambiguous, "expected #{prose.inspect} to match unambiguously"
        assert_equal expected, result.movement&.name, "expected #{prose.inspect} to normalize to #{expected.inspect}"
      end
    end

    test 'matches a space-separated catalog name from hyphenated, pluralized prose' do
      assert_no_difference('Movement.count') do
        result = MovementMatcher.match('pull-ups')

        assert_not result.ambiguous
        assert_equal movements(:pullup), result.movement
      end
    end

    test 'tries the as-written form before singularizing, since some catalog names are inherently plural' do
      Movement.create!(name: 'Knees-to-elbows')

      assert_no_difference('Movement.count') do
        result = MovementMatcher.match('knees-to-elbows')

        assert_not result.ambiguous
        assert_equal 'Knees-to-elbows', result.movement.name
      end
    end

    test 'matches an exact existing name case-insensitively without creating a duplicate' do
      assert_no_difference('Movement.count') do
        result = MovementMatcher.match('THRUSTER')

        assert_equal movements(:thruster), result.movement
      end
    end

    test 'does not create a genuinely missing movement, reports it unmatched instead' do
      assert_no_difference('Movement.count') do
        result = MovementMatcher.match('gorilla crawls')

        assert_not result.ambiguous
        assert_nil result.movement
      end
    end

    test 'flags a bare generic term that fuzzy-matches many catalog movements as ambiguous' do
      assert_no_difference('Movement.count') do
        result = MovementMatcher.match('squats')

        assert result.ambiguous
        assert_nil result.movement
      end
    end

    test 'a misclassified sentence never creates a movement' do
      assert_no_difference('Movement.count') do
        result = MovementMatcher.match('Add 3 reps to each movement every round')

        assert_not result.ambiguous
        assert_nil result.movement
      end
    end
  end
end
