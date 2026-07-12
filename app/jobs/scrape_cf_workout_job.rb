class ScrapeCfWorkoutJob < ApplicationJob
  queue_as :default

  retry_on CfWorkout::Fetcher::FetchError, wait: :polynomially_longer, attempts: 3 do |job, error|
    WorkoutImport.log_failure!(job.arguments.first, error.message)
  end

  # CfWorkout::Fetcher already retries an empty-template response internally
  # (MAX_EMPTY_TEMPLATE_RETRIES). UnrecognizedTemplateError is a FetchError subclass, so without
  # this more specific handler -- declared after, and therefore checked before, the FetchError
  # handler above (rescue_from searches most-recently-declared first) -- the generic retry would
  # stack 3 more job-level attempts on top of Fetcher's own 3, requesting the page up to 9 times
  # before finally giving up.
  retry_on CfWorkout::Fetcher::UnrecognizedTemplateError, attempts: 1 do |job, error|
    WorkoutImport.log_failure!(job.arguments.first, error.message)
  end

  def self.default_date
    ActiveSupport::TimeZone['America/Los_Angeles'].today + 1
  end

  # Pin the resolved date onto the job's own arguments immediately: config/recurring.yml enqueues
  # this job with no args, so `date`'s default is otherwise re-evaluated fresh on every retry
  # (ActiveJob re-invokes `perform` with whatever `arguments` currently holds, and Ruby evaluates
  # an omitted default argument at each call). Without this, a retry that crosses local midnight
  # in America/Los_Angeles would silently target a different day's workout than the attempt before it.
  def perform(date = self.class.default_date)
    self.arguments = [date]

    page = CfWorkout::Fetcher.call(date)
    return if page.rest_day?

    workout = CfWorkout::WorkoutParser.call(page)
    workout = persist(workout)
    Program.find_by!(name: 'Crossfit.com')
           .schedules.find_or_initialize_by(posted_at: date)
           .update!(workout: workout)
    WorkoutImport.clear!(date)
  rescue CfWorkout::WorkoutParser::UnparseableError, ActiveRecord::ActiveRecordError => e
    WorkoutImport.log_failure!(date, e.message, raw_text: page&.body_text)
  end

  private

  def persist(workout)
    return workout if workout.persisted?

    workout.save!
    workout.absorb_duplicate!
  end
end
