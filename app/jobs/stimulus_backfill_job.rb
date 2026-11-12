# Drives the intended-stimulus backfill from the RailsAdmin action (#1992): scrape past
# CrossFit.com days (see StimulusScrapeJob), extract their Stimulus and Strategy prose, then refit the learner and
# write predictions. `run_all` chains the steps; extraction is scheduled to start after the
# last staggered scrape has run.
class StimulusBackfillJob < ApplicationJob
  queue_as :default

  STEPS = %w[run_all scrape extract predict].freeze
  SCRAPE_SETTLE_TIME = 5.minutes

  def perform(step, start_date: nil, end_date: nil, force: false)
    case step
    when 'scrape' then scrape(start_date, end_date)
    when 'extract' then ExtractIntendedStimulusJob.perform_later(force:, then_predict: false)
    when 'predict' then PredictStimulusJob.perform_later
    when 'run_all' then run_all(start_date, end_date, force)
    else raise ArgumentError, "unknown stimulus backfill step #{step.inspect}"
    end
  end

  def self.scrape_wait(start_date, end_date)
    ((end_date - start_date).to_i + 1) * BackfillCrossfitWodsJob::DELAY_BETWEEN_REQUESTS
  end

  private

  def run_all(start_date, end_date, force)
    return ExtractIntendedStimulusJob.perform_later(force:, then_predict: true) unless start_date && end_date

    scrape(start_date, end_date)
    ExtractIntendedStimulusJob.set(wait: self.class.scrape_wait(start_date, end_date) + SCRAPE_SETTLE_TIME)
                              .perform_later(force:, then_predict: true)
  end

  # Staggered like BackfillCrossfitWodsJob, but per day through StimulusScrapeJob so days that
  # already have a schedule only get their prose attached instead of being re-imported.
  def scrape(start_date, end_date)
    raise ArgumentError, 'scrape needs a start_date and end_date' unless start_date && end_date
    raise ArgumentError, 'start_date must be <= end_date' if start_date > end_date

    (start_date..end_date).each_with_index do |date, i|
      StimulusScrapeJob.set(wait: i * BackfillCrossfitWodsJob::DELAY_BETWEEN_REQUESTS).perform_later(date)
    end
  end
end
