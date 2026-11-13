require 'test_helper'
require_relative '../../support/stimulus_test_reference'

module StimulusCalculator
  class TimingTest < ActiveSupport::TestCase
    include StimulusTestReference

    # Fran: 45 light thrusters x 2.0 s + 45 pull-ups x 1.5 s + 5 transitions x 10 s = 207.5 s.
    test 'Fran expected range runs from the fast time to twice it' do
      result = StimulusCalculator.workout(fran, test_reference)

      assert_equal [208, 415], result.values_at(:stimulus_range_low, :stimulus_range_high)
      assert_equal [69, 138], result.values_at(:stimulus_round_seconds_low, :stimulus_round_seconds_high)
      assert_equal 'for_time', result[:stimulus_goal]
    end

    test 'a movement missing from the table blanks the time but keeps covered loading' do
      workout = build_workout('Partial', rounds: 3, movements: [{ movement: movements(:thruster), reps: 15, load: 95 },
                                                                { movement: movements(:burpee), reps: 15 }])

      result = StimulusCalculator.workout(workout, test_reference)

      assert_nil result[:stimulus_range_high]
      assert_equal 'light', StimulusCalculator.exercise(workout.exercises.first, test_reference)[:stimulus_loading]
    end

    # One round: 200 m x 0.25 = 50 s + 10 light thrusters x 2.0 = 20 s + 2 transitions = 90 s; 600 / 90 = 6.7.
    test 'a rounds-scored AMRAP predicts rounds from the time cap' do
      workout = build_workout('AMRAP Calc', score_type: :round, time_seconds: 600,
                                            movements: [{ movement: movements(:run), distance: 200, distance_unit: :meter },
                                                        { movement: movements(:thruster), reps: 10, load: 95 }])

      result = StimulusCalculator.workout(workout, test_reference)

      assert_equal [3, 7], result.values_at(:stimulus_range_low, :stimulus_range_high)
      assert_equal [90, 180], result.values_at(:stimulus_round_seconds_low, :stimulus_round_seconds_high)
      assert_equal 'amrap', result[:stimulus_goal]
    end

    test 'a team workout gets no range' do
      workout = fran
      workout.update!(team_size: 2)

      assert_nil StimulusCalculator.workout(workout, test_reference)[:stimulus_range_high]
    end
  end
end
