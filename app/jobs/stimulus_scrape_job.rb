# One day of the stimulus backfill's scrape (#1992). A day that already has a Crossfit.com
# schedule is never re-parsed -- a fresh parse could fingerprint differently, persist a new
# workout and repoint the schedule away from the one athletes logged against. For those days
# only the page's Stimulus and Strategy prose is attached to the scheduled workout, and only
# when it has none. Unscheduled days go through the normal ScrapeCfWodJob import.
class StimulusScrapeJob < ApplicationJob
  queue_as :default

  retry_on CfWod::Fetcher::FetchError, wait: :polynomially_longer, attempts: 3

  def perform(date)
    schedule = scheduled_on(date)
    return ScrapeCfWodJob.perform_now(date) unless schedule

    workout = schedule.workout
    return if workout.intended_stimulus_notes.present?

    page = CfWod::Fetcher.call(date)
    return if page.rest_day? || page.description.blank?

    workout.update!(intended_stimulus_notes: page.description.sub(ScrapeCfWodJob::STIMULUS_HEADING_PATTERN, ''))
  end

  private

  def scheduled_on(date)
    day = ActiveSupport::TimeZone['America/Los_Angeles'].local(date.year, date.month, date.day).all_day
    Schedule.joins(:program).where(programs: { name: 'Crossfit.com' }, posted_at: day).first
  end
end
