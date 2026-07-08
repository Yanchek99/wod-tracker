require 'test_helper'

module CfWod
  class ExerciseLineParserTest < ActiveSupport::TestCase
    test 'parses a numbered reps line' do
      assert_equal({ movement_name: 'power snatches', reps: 5 }, ExerciseLineParser.call('5 power snatches'))
    end

    test 'strips a trailing comma-qualifier from the movement name' do
      result = ExerciseLineParser.call('1 rope climb, 15-ft. rope')
      assert_equal({ movement_name: 'rope climb', reps: 1 }, result)
    end

    test 'strips a trailing "with" qualifier from the movement name' do
      result = ExerciseLineParser.call('1,600-meter sled drag with a barbell front-rack carry')
      assert_equal({ movement_name: 'sled drag', reps: 1, distance: 1600, distance_unit: :meter }, result)
    end

    test 'parses a leading distance-then-movement line' do
      result = ExerciseLineParser.call('200-meter run')
      assert_equal({ movement_name: 'run', reps: 1, distance: 200, distance_unit: :meter }, result)
    end

    test 'parses a trailing movement-then-distance line' do
      result = ExerciseLineParser.call('Run 800 meters')
      assert_equal({ movement_name: 'Run', reps: 1, distance: 800, distance_unit: :meter }, result)
    end

    test 'parses a numbered reps line with a "to"-joined distance clause' do
      result = ExerciseLineParser.call('5 rope climbs to 15 feet')
      assert_equal({ movement_name: 'rope climbs', reps: 5, distance: 15, distance_unit: :foot }, result)
    end

    test 'parses a bare "Max" line as the reps-zero sentinel' do
      assert_equal({ movement_name: 'skin-the-cats', reps: 0 }, ExerciseLineParser.call('Max skin-the-cats'))
    end

    test 'parses a bare movement-only line as reps 1' do
      assert_equal({ movement_name: 'Thrusters', reps: 1 }, ExerciseLineParser.call('Thrusters'))
    end

    test 'returns nil for a full prose sentence that is not an exercise line' do
      line = 'Any time you stop, you must complete 15 bent-over rows with the barbell before starting again.'
      assert_nil ExerciseLineParser.call(line)
    end

    test 'converts a leading mile distance to canonical meters' do
      result = ExerciseLineParser.call('1-mile run')
      assert_equal({ movement_name: 'run', reps: 1, distance: 1600, distance_unit: :meter }, result)
    end

    test 'converts a trailing mile distance to canonical meters' do
      result = ExerciseLineParser.call('Run 1 mile')
      assert_equal({ movement_name: 'Run', reps: 1, distance: 1600, distance_unit: :meter }, result)
    end

    test 'converts a decimal mile distance to canonical meters' do
      result = ExerciseLineParser.call('1.5-mile run')
      assert_equal({ movement_name: 'run', reps: 1, distance: 2400, distance_unit: :meter }, result)
    end

    test 'strips a trailing parenthetical qualifier from the movement name' do
      assert_equal({ movement_name: 'double-unders', reps: 24 }, ExerciseLineParser.call('24 double-unders (each)'))
      assert_equal({ movement_name: 'clean and jerks', reps: 2 }, ExerciseLineParser.call('2 clean and jerks (total)'))
    end

    test 'strips a trailing parenthetical qualifier after a distance' do
      result = ExerciseLineParser.call('400-meter run (together)')
      assert_equal({ movement_name: 'run', reps: 1, distance: 400, distance_unit: :meter }, result)
    end

    test 'parses a leading calorie-then-movement line' do
      result = ExerciseLineParser.call('40-calorie row')
      assert_equal({ movement_name: 'row', reps: 1, calories: 40 }, result)
    end
  end
end
