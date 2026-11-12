require 'test_helper'
require_relative '../../support/stimulus_examples'

module StimulusLearner
  # Synthetic examples with true paces of 2 s per deadlift and 0.3 s per meter run.
  class PaceTest < ActiveSupport::TestCase
    include StimulusExamples

    setup do
      example('A', rounds: 3, run: 400, deadlifts: 21)
      example('B', rounds: 5, run: 200, deadlifts: 21)
      example('C', rounds: 2, run: 800, deadlifts: 10)
      example('D', rounds: 1, run: nil, deadlifts: 50)
    end

    test 'predicts a for-time range and round time from learned paces' do
      target = target_workout('Target', rounds: 2, movements: [run_leg(400), deadlift(15)])

      result = pace.predict(target)

      assert_in_delta 300, result[:stimulus_range_low], 2
      assert_in_delta 300, result[:stimulus_range_high], 2
      assert_in_delta 150, result[:stimulus_round_seconds_low], 1
      assert_in_delta 150, result[:stimulus_round_seconds_high], 1
    end

    test 'returns nothing when one movement has no pace' do
      target = target_workout('Target', rounds: 2,
                                        movements: [run_leg(400), { movement: movements(:thruster), reps: 15, load: 95 }])

      assert_equal({}, pace.predict(target))
    end

    test 'returns nothing for a weight-scored workout' do
      target = target_workout('Heavy Target', score_type: :weight, movements: [deadlift(5)])

      assert_equal({}, pace.predict(target))
    end

    test 'predicts AMRAP rounds as the time cap divided by the round time' do
      target = target_workout('AMRAP Target', score_type: :round, time_seconds: 600,
                                              movements: [run_leg(200), deadlift(10)])

      result = pace.predict(target)

      assert_equal [7, 8], result.values_at(:stimulus_range_low, :stimulus_range_high)
      assert_equal [80, 80], result.values_at(:stimulus_round_seconds_low, :stimulus_round_seconds_high)
    end

    test 'returns nothing below the per-movement example threshold' do
      assert_equal({}, Pace.new(Examples.load, min_examples: 5).predict(target_workout('T', movements: [run_leg(400)])))
    end

    private

    def pace = Pace.new(Examples.load)

    def run_leg(meters) = { movement: movements(:run), distance: meters, distance_unit: :meter }

    def deadlift(reps) = { movement: movements(:deadlift), reps:, load: 185 }

    def example(name, rounds:, run:, deadlifts:)
      movements = [(run_leg(run) if run), deadlift(deadlifts)].compact
      seconds = rounds * (((run || 0) * 0.3) + (deadlifts * 2))
      labeled_workout("Pace #{name}", rounds:, movements:,
                                      stimulus_range_low: seconds.round, stimulus_range_high: seconds.round)
    end
  end
end
