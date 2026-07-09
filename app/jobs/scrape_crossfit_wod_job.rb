class ScrapeCrossfitWodJob < ApplicationJob
  queue_as :default

  # retry_on's final-failure block runs with `self` bound to the job class (lexical scope, not
  # instance_exec'd on the job instance), so it calls the class methods below rather than a
  # private instance method.
  retry_on CfWod::Fetcher::FetchError, wait: :polynomially_longer, attempts: 3 do |job, error|
    date = job.arguments.first || default_date
    log_failure(date, error.message)
  end

  def self.default_date
    ActiveSupport::TimeZone['America/Los_Angeles'].today + 1
  end

  def self.log_failure(date, message, raw_text: nil)
    WodImport.find_or_initialize_by(wod_date: date)
             .update!(status: :failed, raw_text: raw_text, error_message: message)
  end

  def perform(date = self.class.default_date)
    page = CfWod::Fetcher.call(date)
    return if page.rest_day?

    workout = CfWod::WorkoutParser.call(page)
    workout = persist(workout)
    Program.find_by!(name: 'Crossfit.com')
           .schedules.find_or_initialize_by(posted_at: date)
           .update!(workout: workout)
  rescue CfWod::WorkoutParser::UnparseableError => e
    self.class.log_failure(date, e.message, raw_text: page&.body_text)
  end

  private

  def persist(workout)
    return workout if workout.persisted?

    workout.save!
    workout.absorb_duplicate!
  end
end
