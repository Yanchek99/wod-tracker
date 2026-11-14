require 'test_helper'

class RecalculateStimulusJobTest < ActiveJob::TestCase
  test 'runs the recalculation' do
    called = false
    original = StimulusRecalculation.method(:call)
    StimulusRecalculation.define_singleton_method(:call) { |**| called = true }

    RecalculateStimulusJob.perform_now

    assert called
  ensure
    StimulusRecalculation.define_singleton_method(:call, original)
  end
end
