require 'test_helper'

class StimulusBackfillJobTest < ActiveJob::TestCase
  test 'run_all with dates enqueues a staggered stimulus scrape per day and a delayed extract that then predicts' do
    freeze_time do
      StimulusBackfillJob.perform_now('run_all', start_date: Date.new(2026, 6, 1), end_date: Date.new(2026, 6, 10))

      assert_enqueued_jobs 10, only: StimulusScrapeJob
      assert_enqueued_with(job: StimulusScrapeJob, args: [Date.new(2026, 6, 10)],
                           at: (9 * BackfillCrossfitWodsJob::DELAY_BETWEEN_REQUESTS).from_now)
      assert_enqueued_with(job: ExtractIntendedStimulusJob, args: [{ force: false, then_predict: true }],
                           at: ((10 * BackfillCrossfitWodsJob::DELAY_BETWEEN_REQUESTS) + 5.minutes).from_now)
    end
  end

  test 'run_all without dates extracts then predicts right away' do
    StimulusBackfillJob.perform_now('run_all')

    assert_enqueued_with(job: ExtractIntendedStimulusJob, args: [{ force: false, then_predict: true }])
    assert_no_enqueued_jobs(only: StimulusScrapeJob)
  end

  test 'extract step enqueues extract only, passing force' do
    StimulusBackfillJob.perform_now('extract', force: true)

    assert_enqueued_with(job: ExtractIntendedStimulusJob, args: [{ force: true, then_predict: false }])
    assert_no_enqueued_jobs(only: PredictStimulusJob)
  end

  test 'predict step enqueues predict only' do
    StimulusBackfillJob.perform_now('predict')

    assert_enqueued_with(job: PredictStimulusJob)
    assert_no_enqueued_jobs(only: ExtractIntendedStimulusJob)
  end

  test 'scrape step rejects a start after the end' do
    assert_raises(ArgumentError) do
      StimulusBackfillJob.perform_now('scrape', start_date: Date.new(2026, 6, 10), end_date: Date.new(2026, 6, 1))
    end
  end

  test 'scrape step needs dates' do
    assert_raises(ArgumentError) { StimulusBackfillJob.perform_now('scrape') }
  end
end
