require 'test_helper'

class SugarwodImport
  class NameMatcherTest < ActiveSupport::TestCase
    test 'matches an exact catalog name case-insensitively' do
      assert_equal workouts(:fran), NameMatcher.call('fran')
      assert_equal workouts(:fran), NameMatcher.call('FRAN')
    end

    test 'matches a catalog name wrapped in literal quote marks' do
      assert_equal workouts(:fran), NameMatcher.call('"Fran"')
    end

    test 'matches a catalog name that differs from the title only by spacing' do
      workout = Workout.create!(name: 'Hotshots 19', score_type: :time)
      assert_equal workout, NameMatcher.call('Hot Shots 19')
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

    test 'does not match an Open-numbered workout when the title names a different competition stage' do
      Workout.create!(name: 'Open 22.4', score_type: :time)
      quarterfinals = Workout.create!(name: 'Quarterfinals 22.4', score_type: :weight)

      assert_equal quarterfinals, NameMatcher.call('Quarterfinals 22.4')
    end

    test 'returns nil rather than guessing when a stage-mismatched number has no same-stage catalog match' do
      Workout.create!(name: 'Open 22.4', score_type: :time)

      assert_nil NameMatcher.call('Quarterfinals 22.4')
    end

    test 'matches a Regionals-prefixed number against its same-stage catalog entry' do
      Workout.create!(name: 'Open 18.5', score_type: :time)
      regionals = Workout.create!(name: 'Regionals 18.5', score_type: :time)

      assert_equal regionals, NameMatcher.call('REGIONALS 18.5')
    end

    test 'resolves a known repeat title to its canonical seeded workout' do
      canonical = Workout.create!(name: 'Open 16.2', score_type: :rep)

      assert_equal canonical, NameMatcher.call('Open 19.2')
    end

    test 'resolves the other two known repeat titles' do
      open171 = Workout.create!(name: 'Open 17.1', score_type: :time)
      open144 = Workout.create!(name: 'Open 14.4', score_type: :rep)

      assert_equal open171, NameMatcher.call('Open 21.2')
      assert_equal open144, NameMatcher.call('Open 23.1')
    end
  end
end
