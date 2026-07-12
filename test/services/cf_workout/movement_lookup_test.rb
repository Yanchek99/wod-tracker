require 'test_helper'

module CfWorkout
  class MovementLookupTest < ActiveSupport::TestCase
    test 'normalizes a plural movement phrase and finds an exact match' do
      assert_equal movements(:power_snatch), MovementLookup.call('power snatches')
    end

    test 'singularizes without breaking a hyphenated suffix' do
      assert_equal movements(:sled_drag), MovementLookup.call('sled drag')
      assert_equal movements(:pull_up), MovementLookup.call('pull-ups')
    end

    test 'strips a trailing period' do
      assert_equal movements(:rope_climb), MovementLookup.call('Rope Climb.')
    end

    test 'returns nil for a name with no catalog match' do
      assert_nil MovementLookup.call('a completely unrecognized movement phrase')
    end

    test 'keeps connector words lowercase except as the first word' do
      clean_and_jerk = Movement.find_or_create_by(name: 'Clean and Jerk')
      assert_equal clean_and_jerk, MovementLookup.call('clean and jerks')
    end

    test 'falls back to treating a hyphenated compound as space-separated words' do
      toes_to_bar = Movement.find_or_create_by(name: 'Toes to Bar')
      assert_equal toes_to_bar, MovementLookup.call('toes-to-bars')
    end
  end
end
