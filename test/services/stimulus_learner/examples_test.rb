require 'test_helper'
require_relative '../../support/stimulus_examples'

module StimulusLearner
  class ExamplesTest < ActiveSupport::TestCase
    include StimulusExamples

    test 'volume expands an interval scheme from the segment' do
      thruster = exercises(:fran_thruster)

      assert_equal 45, Examples.volume(thruster)[:reps]
    end

    test 'volume multiplies reps, distance and calories by rounds' do
      workout = target_workout('Rounds Volume', rounds: 3,
                                                movements: [{ movement: movements(:deadlift), reps: 21, load: 185 },
                                                            { movement: movements(:run), distance: 400, distance_unit: :meter }])
      deadlift, run = workout.exercises.to_a

      assert_equal 63, Examples.volume(deadlift)[:reps]
      assert_equal({ distance_meter: 1200 }, Examples.volume(run))
    end

    test 'loads only extracted or authored labels' do
      labeled_workout('Labeled', movements: [{ movement: movements(:deadlift), reps: 5, load: 315,
                                               stimulus_loading: :heavy }])
      target_workout('Unlabeled', movements: [{ movement: movements(:deadlift), reps: 5, load: 315 }])

      examples = Examples.load

      assert_equal ['Labeled'], examples.workouts.map(&:name)
      assert_equal 1, examples.exercises.size
    end
  end
end
