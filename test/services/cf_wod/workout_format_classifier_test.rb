require 'test_helper'

module CfWod
  class WorkoutFormatClassifierTest < ActiveSupport::TestCase
    test 'classifies a for-time header' do
      assert_equal({ score_type: :time }, WorkoutFormatClassifier.call('For time:'))
    end

    test 'classifies a for-load header' do
      assert_equal({ score_type: :weight }, WorkoutFormatClassifier.call('For load:'))
    end

    test 'classifies an AMRAP header, extracting the time cap' do
      result = WorkoutFormatClassifier.call('Complete as many rounds as possible in 10 minutes of:')
      assert_equal({ score_type: :rep, time: 10 }, result)
    end

    test 'classifies a reps-only AMRAP header, extracting the time cap' do
      result = WorkoutFormatClassifier.call('Complete as many reps as possible in 10 minutes of:')
      assert_equal({ score_type: :rep, time: 10 }, result)
    end

    test 'classifies an every-minute-on-the-minute header, extracting rounds and time' do
      result = WorkoutFormatClassifier.call('Every minute on the minute for 10 minutes:')
      assert_equal({ score_type: :rep, time: 10, rounds: 10 }, result)
    end

    test 'classifies a rep-ladder header, extracting the interval scheme' do
      result = WorkoutFormatClassifier.call('21-15-9 reps for time of:')
      assert_equal({ score_type: :time, interval: '21-15-9' }, result)
    end

    test 'classifies a find-a-1-rep-max header, extracting the lift name' do
      result = WorkoutFormatClassifier.call('Find a 1-rep-max back squat.')
      assert_equal({ score_type: :weight, lift_name: 'back squat' }, result)
    end

    test 'raises UnparseableError on an unrecognized header' do
      assert_raises(WorkoutParser::UnparseableError) do
        WorkoutFormatClassifier.call('Some completely novel workout format:')
      end
    end

    test 'classifies a rounds-for-time header, extracting the round count' do
      result = WorkoutFormatClassifier.call('5 rounds for time of:')
      assert_equal({ score_type: :time, rounds: 5 }, result)
    end

    test 'classifies a set-based lifting header, extracting the lift name, set count, and reps per set' do
      result = WorkoutFormatClassifier.call('Front squat 3-3-3-3-3 reps')
      assert_equal({ score_type: :weight, rounds: 5, lift_name: 'Front squat', set_reps: 3 }, result)
    end

    test 'raises UnparseableError for a set-based lifting header with a varying rep scheme' do
      assert_raises(WorkoutParser::UnparseableError) do
        WorkoutFormatClassifier.call('Front squat 5-3-3-1-1 reps')
      end
    end

    test 'classifies a "With a partner," rounds-for-time header, extracting team_size' do
      result = WorkoutFormatClassifier.call('With a partner, 5 rounds for time of:')
      assert_equal({ score_type: :time, rounds: 5, team_size: 2 }, result)
    end
  end
end
