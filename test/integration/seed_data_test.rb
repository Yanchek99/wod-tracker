require 'test_helper'

class SeedDataTest < ActiveSupport::TestCase
  WORKOUT_SEED_FILES = %w[benchmark_workouts hero_workouts open_workouts cf_workouts].freeze

  test 'every seeded substitution names seeded movements and owns its pair once' do
    pairs = seed_source('movement_substitutions').scan(/\['([^']+)', '([^']+)', :(\w+)\]/)

    assert_not_empty pairs
    assert_empty pairs.flat_map { |movement, substitute, _| [movement, substitute] } - seeded_movement_names
    assert_empty pairs.map { |_, _, direction| direction } - MovementSubstitution::DIRECTIONS.keys.map(&:to_s)
    assert_empty(pairs.select { |movement, substitute, _| movement == substitute })

    unordered = pairs.map { |movement, substitute, _| [movement, substitute].sort }

    assert_equal unordered.uniq.size, unordered.size, 'a movement pair appears more than once'
  end

  test 'every workout stimulus entry names a seeded workout with an ordered range' do
    entries = seed_source('workout_stimulus').scan(/^  '((?:[^'\\]|\\.)+)' => \{\s*range: \[(\w+), (\w+)\]/)

    assert_not_empty entries
    assert_empty entries.map { |name, _, _| name.delete('\\') } - seeded_workout_names

    entries.each do |name, low, high|
      next if low == 'nil' || high == 'nil'

      assert_operator Integer(high), :>=, Integer(low), "#{name} range is reversed"
    end
  end

  private

  def seed_source(name)
    Rails.root.join('db/seeds', "#{name}.rb").read
  end

  def seeded_movement_names
    Rails.root.join('db/seeds.rb').read.scan(/Movement\.find_or_(?:create|initialize)_by\(name: '([^']+)'\)/).flatten
  end

  def seeded_workout_names
    WORKOUT_SEED_FILES.flat_map do |file|
      seed_source(file).scan(/Workout\.find_or_create_by\(name: (?:'([^']+)'|"([^"]+)")\)/).flatten.compact
    end
  end
end
