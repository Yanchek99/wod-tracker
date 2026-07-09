class ScrapeCrossfitWodJob < ApplicationJob
  queue_as :default

  # retry_on's final-failure block runs with `self` bound to the job class (lexical scope, not
  # instance_exec'd on the job instance), so it can't reach a private instance method -- hence
  # the inlined date expression here matching `perform`'s default, rather than a shared helper.
  retry_on CfWod::Fetcher::FetchError, wait: :polynomially_longer, attempts: 3 do |job, error|
    date = job.arguments.first || ActiveSupport::TimeZone['America/Los_Angeles'].today + 1
    WodImport.find_or_initialize_by(wod_date: date)
             .update!(status: :failed, error_message: error.message)
  end

  def perform(date = ActiveSupport::TimeZone['America/Los_Angeles'].today + 1)
    page = CfWod::Fetcher.call(date)
    return if page.rest_day?

    workout = CfWod::WorkoutParser.call(page)
    workout = persist(workout)
    Program.find_by!(name: 'Crossfit.com')
      .schedules.find_or_initialize_by(posted_at: date)
      .update!(workout: workout)
  rescue CfWod::WorkoutParser::UnparseableError => e
    WodImport.find_or_initialize_by(wod_date: date)
             .update!(status: :failed, raw_text: page&.body_text, error_message: e.message)
  end

  private

  def persist(workout)
    return workout if workout.persisted?

    workout.save!
    workout.absorb_duplicate!
  end
end
