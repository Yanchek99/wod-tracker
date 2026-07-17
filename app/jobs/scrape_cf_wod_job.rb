class ScrapeCfWodJob < ApplicationJob
  queue_as :default

  # Keyed lookup of the two available extraction strategies, so `perform` can pick one at
  # runtime (default :llm) without hardcoding either parser's call signature inline. :heuristic
  # is kept available as a fallback -- e.g. `ScrapeCfWodJob.perform_later(date, :heuristic)` --
  # in case the LLM parser needs to be bypassed for a given date.
  PARSERS = {
    llm: ->(page, date) { WorkoutExtraction::LlmParser.call(page.body_text, date: date) },
    heuristic: ->(page, _date) { CfWod::WorkoutParser.call(page) }
  }.freeze

  retry_on CfWod::Fetcher::FetchError, wait: :polynomially_longer, attempts: 3 do |job, error|
    WorkoutImport.log_failure!(job.arguments.first, error.message)
  end

  # CfWod::Fetcher already retries an empty-template response internally
  # (MAX_EMPTY_TEMPLATE_RETRIES). UnrecognizedTemplateError is a FetchError subclass, so without
  # this more specific handler -- declared after, and therefore checked before, the FetchError
  # handler above (rescue_from searches most-recently-declared first) -- the generic retry would
  # stack 3 more job-level attempts on top of Fetcher's own 3, requesting the page up to 9 times
  # before finally giving up.
  retry_on CfWod::Fetcher::UnrecognizedTemplateError, attempts: 1 do |job, error|
    WorkoutImport.log_failure!(job.arguments.first, error.message)
  end

  def self.default_date
    ActiveSupport::TimeZone['America/Los_Angeles'].today + 1
  end

  # Pin the resolved date (and chosen parser) onto the job's own arguments immediately:
  # config/recurring.yml enqueues this job with no args, so `date`'s default is otherwise
  # re-evaluated fresh on every retry (ActiveJob re-invokes `perform` with whatever `arguments`
  # currently holds, and Ruby evaluates an omitted default argument at each call). Without this, a
  # retry that crosses local midnight in America/Los_Angeles would silently target a different
  # day's workout than the attempt before it -- and would silently fall back to the default parser
  # on retry if `parser` were left unpinned.
  def perform(date = self.class.default_date, parser = :llm)
    self.arguments = [date, parser]

    page = CfWod::Fetcher.call(date)
    return if page.rest_day?

    workout = PARSERS.fetch(parser).call(page, date)
    workout = persist(workout)
    Program.find_by!(name: 'Crossfit.com')
           .schedules.find_or_initialize_by(posted_at: date)
           .update!(workout: workout)
    WorkoutImport.clear!(date)
  rescue CfWod::WorkoutParser::UnparseableError,
         WorkoutExtraction::LlmParser::ExtractionError,
         WorkoutExtraction::LlmParser::UnrepresentableWorkoutError,
         ActiveRecord::ActiveRecordError => e
    WorkoutImport.log_failure!(date, e.message, raw_text: page&.body_text)
  end

  private

  def persist(workout)
    return workout if workout.persisted?

    workout.save!
    workout.absorb_duplicate!
  end
end
