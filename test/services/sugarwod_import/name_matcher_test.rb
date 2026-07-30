require 'test_helper'

class SugarwodImport
  class NameMatcherTest < ActiveSupport::TestCase
    test 'matches an exact catalog name case-insensitively' do
      assert_equal workouts(:fran), NameMatcher.call('fran')
      assert_equal workouts(:fran), NameMatcher.call('FRAN')
    end

    test 'returns nil when no catalog workout matches' do
      assert_nil NameMatcher.call('Not A Real Workout')
    end

    test 'matches an Open workout by number when the title spells out the minor version as a word' do
      open_workout = Workout.create!(name: 'Open Workout 18.0', score_type: :time)
      assert_equal open_workout, NameMatcher.call('18.Zero')
    end

    test 'matches an Open workout by number when the title uses digits' do
      open_workout = Workout.create!(name: 'Open Workout 24.1', score_type: :time)
      assert_equal open_workout, NameMatcher.call('Open 24.1')
    end
  end
end
