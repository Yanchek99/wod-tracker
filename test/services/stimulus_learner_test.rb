require 'test_helper'
require_relative '../support/stimulus_examples'

class StimulusLearnerTest < ActiveSupport::TestCase
  include StimulusExamples

  setup do
    [95, 105].each { |load| clean_and_jerk_example(:light, load) }
    [135, 155].each { |load| clean_and_jerk_example(:moderate, load) }
    [225].each { |load| clean_and_jerk_example(:heavy, load) }
    @target = target_workout('Grace-like', movements: [{ movement: movements(:clean_and_jerk), reps: 30, load: 135 },
                                                       { movement: movements(:pullup), reps: 10 }])
    @clean_and_jerk, @pullup = @target.exercises.to_a
  end

  test 'writes one combined exercise row, predicted when any field is learned' do
    StimulusLearner.call

    row = @clean_and_jerk.stimulus_predictions.current.sole
    assert_equal %w[moderate predicted learned-v1], row.values_at(:stimulus_loading, :source, :model_version)
    assert_in_delta 0.5, row.confidence
  end

  test 'writes a derived rules-v1 row when only the unloaded rule applies' do
    StimulusLearner.call

    row = @pullup.stimulus_predictions.current.sole
    assert_equal %w[unloaded derived rules-v1], row.values_at(:stimulus_loading, :source, :model_version)
  end

  test 'skips fields that have extracted values' do
    @clean_and_jerk.update!(stimulus_loading: :heavy, stimulus_source: :extracted)

    StimulusLearner.call

    assert_empty @clean_and_jerk.stimulus_predictions
  end

  test 'a rerun writes nothing new' do
    StimulusLearner.call

    assert_no_difference('StimulusPrediction.count') { StimulusLearner.call }
  end

  test 'dry run writes nothing and reports counts' do
    result = nil
    assert_no_difference('StimulusPrediction.count') { result = StimulusLearner.call(dry_run: true) }

    assert_operator result.exercises_written, :>=, 2
  end

  private

  def clean_and_jerk_example(label, load)
    labeled_workout("C&J #{label} #{load}", movements: [{ movement: movements(:clean_and_jerk), reps: 10, load:,
                                                          stimulus_loading: label }])
  end
end
