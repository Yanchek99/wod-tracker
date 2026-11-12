require 'test_helper'

class ExtractIntendedStimulusJobTest < ActiveJob::TestCase
  setup do
    @calls = []
    calls = @calls
    @original_call = IntendedStimulusBackfill.method(:call)
    IntendedStimulusBackfill.define_singleton_method(:call) { |**kwargs| calls << kwargs }
  end

  teardown do
    IntendedStimulusBackfill.define_singleton_method(:call, @original_call)
  end

  test 'runs the backfill without enqueueing predictions by default' do
    assert_no_enqueued_jobs(only: PredictStimulusJob) { ExtractIntendedStimulusJob.perform_now }

    assert_equal [{ force: false }], @calls
  end

  test 'passes force and enqueues predictions when asked' do
    assert_enqueued_with(job: PredictStimulusJob) do
      ExtractIntendedStimulusJob.perform_now(force: true, then_predict: true)
    end

    assert_equal [{ force: true }], @calls
  end
end
