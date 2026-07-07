require 'test_helper'

module CfWod
  class WorkoutFormatClassifierTest < ActiveSupport::TestCase
    test 'classifies a for-time header' do
      assert_equal({ score_type: :time }, WorkoutFormatClassifier.call('For time:'))
    end

    test 'classifies an AMRAP header, extracting the time cap' do
      result = WorkoutFormatClassifier.call('Complete as many rounds as possible in 10 minutes of:')
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
  end
end
