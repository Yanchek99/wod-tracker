require 'test_helper'
require_relative '../../support/stimulus_test_reference'

module StimulusCalculator
  class IntervalTest < ActiveSupport::TestCase
    include StimulusTestReference

    # EMOM 10: 10 light thrusters x 2.0 s = 20 s of work in each 60 s interval.
    test 'an EMOM gets interval work and minimum rest' do
      workout = build_workout('EMOM Calc', score_type: :rep, time_seconds: 600, rounds: 10,
                                           movements: [{ movement: movements(:thruster), reps: 10, load: 95 }])

      result = StimulusCalculator.workout(workout, test_reference)

      assert_equal 'intervals', result[:stimulus_goal]
      assert_equal [20, 40], result.values_at(:stimulus_interval_work_seconds, :stimulus_interval_rest_seconds_min)
      assert_nil result[:stimulus_range_high]
    end

    test 'interval scheme volume expands' do
      assert_equal({ rep: 45 }, StimulusCalculator::Volume.for(fran.exercises.second))
    end
  end
end
