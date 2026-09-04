class ScrapeCfWodJob < ApplicationJob
  queue_as :default

  # Keyed lookup of the two available extraction strategies, so `perform` can pick one at
  # runtime without hardcoding either parser's call signature inline. The primary strategy
  # defaults to Rails.application.config.workout_parser, overridable per call (e.g.
  # `ScrapeCfWodJob.perform_later(date, :heuristic)`).
  PARSERS = {
    llm: ->(page, date) { WorkoutExtraction::LlmParser.call(page.body_text, date: date) },
    heuristic: ->(page, _date) { CfWod::WorkoutParser.call(page) }
  }.freeze

  # Each parser's own "couldn't extract a workout" exception class(es) -- extract_workout
  # rescues exactly these for the primary strategy before retrying with its fallback, and
  # `perform`'s own rescue clause (below) rescues the flattened set of all of them, so a fallback
  # that also fails still lands as a WorkoutImport failure instead of an unhandled job error.
  PARSER_ERRORS = {
    llm: [WorkoutExtraction::LlmParser::ExtractionError, WorkoutExtraction::LlmParser::UnrepresentableWorkoutError].freeze,
    heuristic: [CfWod::WorkoutParser::UnparseableError].freeze
  }.freeze

  # The other strategy to fall back to when the primary one fails to extract a workout.
  FALLBACKS = { llm: :heuristic, heuristic: :llm }.freeze

  # CfWod::PageParser::SECTION_MARKERS classifies a paragraph into WodPage#description by its
  # leading <strong> heading, but (deliberately -- see CfWod::FetcherTest) keeps that heading text
  # in the paragraph itself. Strip it back off here: it's a section label from the source page's
  # layout, not part of the coach's own prose.
  STIMULUS_HEADING_PATTERN = /\AStimulus and Strategy:?\s*/i

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
  def perform(date = self.class.default_date, parser = Rails.application.config.workout_parser)
    self.arguments = [date, parser]

    page = CfWod::Fetcher.call(date)
    return if page.rest_day?

    workout = extract_workout(page, date, parser)
    attach_intended_stimulus(workout, page)
    workout = persist(workout)
    extract_structured_stimulus(workout)
    Program.find_by!(name: 'Crossfit.com')
           .schedules.find_or_initialize_by(posted_at: posted_at_for(date))
           .update!(workout: workout)
    WorkoutImport.clear!(date)
  rescue *PARSER_ERRORS.values.flatten, ActiveRecord::ActiveRecordError => e
    WorkoutImport.log_failure!(date, e.message, raw_text: page&.body_text)
  end

  private

  # The app's Time.zone (and therefore ActiveRecord's datetime casting) is UTC, so assigning a
  # bare Date to posted_at would land at midnight UTC on that date -- an instant that falls on the
  # *previous* calendar day once a US-timezone browser localizes it for display. Anchoring to 6pm
  # Pacific instead -- CrossFit.com's own daily posting time -- keeps the stored instant safely
  # within the intended calendar day for any continental US timezone.
  def posted_at_for(date)
    ActiveSupport::TimeZone['America/Los_Angeles'].local(date.year, date.month, date.day, 18)
  end

  # Try the primary parser; if it fails with its own "couldn't extract a workout" error, retry
  # once with the other parser instead of failing the job outright. A failure from the fallback
  # itself is not rescued here -- it propagates to perform's own rescue clause, which logs the
  # WorkoutImport failure once both strategies have been tried.
  def extract_workout(page, date, parser)
    PARSERS.fetch(parser).call(page, date)
  rescue *PARSER_ERRORS.fetch(parser)
    PARSERS.fetch(FALLBACKS.fetch(parser)).call(page, date)
  end

  # The "Stimulus and Strategy" paragraph is parsed into WodPage#description, but neither
  # parser consumes it. Keep the raw prose as the workout's intended-stimulus source of truth
  # (the structured stimulus fields are populated separately, later). Only for a freshly
  # derived workout -- never overwrite an existing catalog record's curated notes.
  def attach_intended_stimulus(workout, page)
    return unless workout.new_record?
    return if workout.intended_stimulus_notes.present? || page.description.blank?

    workout.intended_stimulus_notes = page.description.sub(STIMULUS_HEADING_PATTERN, '')
  end

  # Structure the raw "Stimulus and Strategy" prose into the workout's stimulus_range_* and its
  # exercises' stimulus_loading/sets_max/duration_max via one LLM call. Best-effort: a failure
  # here never fails the import, and a workout that already has extracted/authored values is
  # skipped so re-scrapes don't re-spend the call.
  def extract_structured_stimulus(workout)
    return if workout.intended_stimulus_notes.blank?
    return if workout.stimulus_source.present? || workout.stimulus_range_low.present? || workout.stimulus_range_high.present?

    WorkoutExtraction::IntendedStimulusParser.call(workout)
  rescue WorkoutExtraction::IntendedStimulusParser::ExtractionError => e
    Rails.logger.warn("[ScrapeCfWodJob] intended-stimulus extraction skipped: #{e.message}")
  end

  def persist(workout)
    return workout if workout.persisted?

    catalog = catalog_workout_named(workout.name)
    return catalog if catalog

    workout.save!
    workout.absorb_duplicate!
  end

  # A scraped benchmark (e.g. "Fight Gone Bad") carries its catalog name verbatim, and its
  # prescription is already modeled under that name. Resolve to the existing record rather than
  # persisting a structurally different re-derivation as a duplicate -- content_fingerprint dedup
  # can't catch that, since two valid models of one workout fingerprint differently. This gives
  # the LLM parser the catalog-name match CfWod::WorkoutParser#find_named_workout already does for
  # the heuristic path (a no-op there -- that parser returns the persisted catalog record itself).
  def catalog_workout_named(name)
    name = name.to_s.strip
    Workout.find_by(name: name) if name.present?
  end
end
