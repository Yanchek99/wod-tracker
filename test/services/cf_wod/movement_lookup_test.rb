require 'test_helper'

module CfWod
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

    test 'matches connector-word names case insensitively' do
      clean_and_jerk = Movement.find_or_create_by(name: 'Clean and Jerk')
      assert_equal clean_and_jerk, MovementLookup.call('clean and jerks')
    end

    test 'falls back to treating a hyphenated compound as space-separated words' do
      toes_to_bar = Movement.find_or_create_by(name: 'Toes to Bar')
      assert_equal toes_to_bar, MovementLookup.call('toes-to-bars')
    end

    test 'matches catalog acronyms case insensitively' do
      ghd_sit_up = Movement.find_or_create_by(name: 'GHD Sit-up')
      assert_equal ghd_sit_up, MovementLookup.call('GHD sit-ups')
    end

    test 'aliases bike brand names to the canonical Air Bike movement' do
      air_bike = Movement.find_or_create_by(name: 'Air Bike')
      assert_equal air_bike, MovementLookup.call('bike')
      assert_equal air_bike, MovementLookup.call('Assault Bike')
      assert_equal air_bike, MovementLookup.call('echo bike')
    end

    test 'matches an inherently-plural compound name without singularizing it away' do
      knees_to_elbows = Movement.find_or_create_by(name: 'Knees-to-elbows')
      assert_equal knees_to_elbows, MovementLookup.call('knees-to-elbows')
    end

    test 'matches a space-separated input against a hyphenated catalog entry' do
      hand_release_push_up = Movement.find_or_create_by(name: 'Hand-release Push-up')
      assert_equal hand_release_push_up, MovementLookup.call('hand release push ups')
    end

    test 'matches past a trailing parenthetical annotation on the catalog entry' do
      pistol_squat = Movement.find_or_create_by(name: 'Pistol Squat (Single-leg)')
      assert_equal pistol_squat, MovementLookup.call('pistol squats')
    end
  end
end
