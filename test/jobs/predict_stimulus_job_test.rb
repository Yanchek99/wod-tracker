require 'test_helper'

class PredictStimulusJobTest < ActiveJob::TestCase
  test 'runs the stimulus learner' do
    called = false
    original = StimulusLearner.method(:call)
    StimulusLearner.define_singleton_method(:call) { |**| called = true }

    PredictStimulusJob.perform_now

    assert called
  ensure
    StimulusLearner.define_singleton_method(:call, original)
  end
end
