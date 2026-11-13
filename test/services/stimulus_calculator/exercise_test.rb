require 'test_helper'
require_relative '../../support/stimulus_test_reference'

module StimulusCalculator
  class ExerciseTest < ActiveSupport::TestCase
    include StimulusTestReference

    test 'sets guide from the load class chunk: 21 moderate reps -> 3 sets' do
      workout = build_workout('Diane-ish', interval_scheme: '21-15-9',
                                           movements: [{ movement: movements(:deadlift), reps: 1, load: 225 }])

      assert_equal 3, StimulusCalculator.exercise(workout.exercises.first, test_reference)[:stimulus_sets_max]
    end

    test 'a light set within one chunk is a single unbroken set' do
      result = StimulusCalculator.exercise(fran.exercises.first, test_reference)

      assert_equal 'light', result[:stimulus_loading]
      assert_equal 2, result[:stimulus_sets_max] # 21 / 15 rounded up
    end

    # Fran's first thruster set: 21 x 2.0 = 42 s fast -> sprint; ceiling 21 x 2.0 x 2 = 84 s.
    test 'time ceiling and effort come from one effort' do
      result = StimulusCalculator.exercise(fran.exercises.first, test_reference)

      assert_equal [84, 'sprint'], result.values_at(:stimulus_duration_max, :stimulus_effort)
    end

    test 'effort cut-offs: a 2-minute effort is hard, a 5-minute one is threshold' do
      hard = build_workout('Hard', movements: [{ movement: movements(:run), distance: 480, distance_unit: :meter }])
      threshold = build_workout('Threshold', movements: [{ movement: movements(:run), distance: 1200, distance_unit: :meter }])

      assert_equal 'hard', StimulusCalculator.exercise(hard.exercises.first, test_reference)[:stimulus_effort]
      assert_equal 'threshold', StimulusCalculator.exercise(threshold.exercises.first, test_reference)[:stimulus_effort]
    end

    test 'an unloaded movement gets no sets guide' do
      assert_nil StimulusCalculator.exercise(fran.exercises.second, test_reference)[:stimulus_sets_max]
    end
  end
end
