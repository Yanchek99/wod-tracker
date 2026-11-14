require 'test_helper'
require_relative '../../support/stimulus_test_reference'

module StimulusCalculator
  class HeavyDayTest < ActiveSupport::TestCase
    include StimulusTestReference

    # Epley: 100 / (1 + 3/30) = 90.9 -> 89..93 % of 1RM.
    test 'build to a 3-rep max finds a max with an Epley result range' do
      workout = build_workout('Build to a 3-rep-max back squat', score_type: :weight, time_seconds: 1200,
                                                                 movements: [{ movement: movements(:back_squat), reps: 3 }])

      result = StimulusCalculator.workout(workout, test_reference)

      assert_equal 'heavy_find_max', result[:stimulus_goal]
      assert_equal [89, 93], result.values_at(:stimulus_range_low, :stimulus_range_high)
      assert_equal [180, 300], result.values_at(:stimulus_rest_seconds_low, :stimulus_rest_seconds_high)
      assert_equal 80, result[:stimulus_percent_1rm_low]
    end

    test 'a stated percentage holds that percentage' do
      workout = build_workout('Push Press @ 75%', score_type: :weight, rounds: 5,
                                                  movements: [{ movement: movements(:back_squat), reps: 5,
                                                                notes: 'All sets at 75% of 1RM' }])

      result = StimulusCalculator.workout(workout, test_reference)

      assert_equal 'heavy_hold_percent', result[:stimulus_goal]
      assert_equal [75, 75], result.values_at(:stimulus_percent_1rm_low, :stimulus_percent_1rm_high)
      assert_equal [75, 75], result.values_at(:stimulus_range_low, :stimulus_range_high)
      assert_equal [5, 5], result.values_at(:stimulus_working_sets_low, :stimulus_working_sets_high)
    end

    test 'a 5x5 back squat scored for load adds load each set' do
      workout = build_workout('Back Squat 5x5', score_type: :weight, rounds: 5,
                                                movements: [{ movement: movements(:back_squat), reps: 5 }])

      result = StimulusCalculator.workout(workout, test_reference)

      assert_equal 'heavy_ascending', result[:stimulus_goal]
      assert_equal [5, 5], result.values_at(:stimulus_working_sets_low, :stimulus_working_sets_high)
      assert_equal [84, 88], result.values_at(:stimulus_range_low, :stimulus_range_high) # 100 / (1 + 5/30) = 85.7
    end
  end
end
