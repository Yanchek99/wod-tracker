require 'test_helper'
require_relative '../../support/stimulus_examples'

module StimulusLearner
  class FieldLearnerTest < ActiveSupport::TestCase
    include StimulusExamples

    test 'takes the majority label for a workout goal among matching structures' do
      4.times { |i| heavy_example("Hold #{i}", goal: :heavy_hold_percent) }
      heavy_example('Build', goal: :heavy_ascending)

      learner = FieldLearner.new(Examples.load, fields: %w[stimulus_goal])

      assert_equal({ stimulus_goal: 'heavy_hold_percent' }, learner.predict(heavy_target))
      assert_equal 5, learner.support(heavy_target)
    end

    test 'takes the interquartile range for a numeric pair' do
      [4, 5, 5, 6, 8].each_with_index do |sets, i|
        heavy_example("Sets #{i}", goal: :heavy_ascending, stimulus_working_sets_low: sets, stimulus_working_sets_high: sets)
      end

      learner = FieldLearner.new(Examples.load, fields: %w[stimulus_working_sets_low stimulus_working_sets_high])

      assert_equal({ stimulus_working_sets_low: 5, stimulus_working_sets_high: 6 }, learner.predict(heavy_target))
    end

    test 'returns nothing below the threshold' do
      4.times { |i| heavy_example("Hold #{i}", goal: :heavy_hold_percent) }

      assert_equal({}, FieldLearner.new(Examples.load, fields: %w[stimulus_goal]).predict(heavy_target))
    end

    test 'learns a per-movement field from exercises of the same movement' do
      5.times do |i|
        labeled_workout("Run #{i}", rounds: 4, movements: [{ movement: movements(:run), distance: 400, distance_unit: :meter,
                                                             stimulus_effort: :sprint }])
      end
      target = target_workout('Run Target', rounds: 6, movements: [{ movement: movements(:run), distance: 400,
                                                                     distance_unit: :meter }])

      learner = FieldLearner.new(Examples.load, fields: %w[stimulus_effort])

      assert_equal({ stimulus_effort: 'sprint' }, learner.predict(target.exercises.first))
    end

    private

    def heavy_example(name, goal:, **stimulus)
      labeled_workout(name, score_type: :weight, rounds: 5, stimulus_goal: goal,
                            movements: [{ movement: movements(:back_squat), reps: 5, load: 0 }], **stimulus)
    end

    def heavy_target
      target_workout('Heavy Target', score_type: :weight, rounds: 5,
                                     movements: [{ movement: movements(:back_squat), reps: 3, load: 0 }])
    end
  end
end
