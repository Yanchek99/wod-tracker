require 'test_helper'

module CfWod
  class MovementMatcherTest < ActiveSupport::TestCase
    test 'normalizes and matches existing catalog movements regardless of prose pluralization' do
      {
        'pull-ups' => 'Pull-up',
        'push-ups' => 'Push-up',
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

    test 'matches an exact existing name case-insensitively without creating a duplicate' do
      assert_no_difference('Movement.count') do
        result = MovementMatcher.match('THRUSTER')

        assert_equal movements(:thruster), result.movement
      end
    end

    test 'creates a genuinely missing movement' do
      assert_difference('Movement.count', 1) do
        result = MovementMatcher.match('gorilla crawls')

        assert_not result.ambiguous
        assert_equal 'Gorilla Crawl', result.movement.name
      end
    end

    test 'flags a bare generic term that fuzzy-matches many catalog movements as ambiguous' do
      assert_no_difference('Movement.count') do
        result = MovementMatcher.match('squats')

        assert result.ambiguous
        assert_nil result.movement
      end
    end

    test 'refuses to create a movement from an implausibly long candidate' do
      assert_no_difference('Movement.count') do
        result = MovementMatcher.match('Add 3 reps to each movement every round')

        assert_not result.ambiguous
        assert_nil result.movement
      end
    end
  end
end
