# Attaches CrossFit's posted Stimulus and Strategy text to a workout the app already has, via the
# Crossfit.com schedule that placed it on that day (#1992). Never parses or imports a workout and
# never calls an LLM: only the page's stimulus paragraph is saved, and only when the workout has
# no notes. The text feeds the stimulus accuracy check (StimulusAccuracy).
class FetchStimulusTextJob < ApplicationJob
  queue_as :default

  retry_on CfWod::Fetcher::FetchError, wait: :polynomially_longer, attempts: 3

  def perform(schedule_id)
    schedule = Schedule.find_by(id: schedule_id)
    workout = schedule&.workout
    return if workout.nil? || workout.intended_stimulus_notes.present?

    page = CfWod::Fetcher.call(schedule.posted_at.in_time_zone('America/Los_Angeles').to_date)
    return if page.rest_day? || page.description.blank?

    workout.update!(intended_stimulus_notes: page.description.sub(ScrapeCfWodJob::STIMULUS_HEADING_PATTERN, ''))
  end
end
