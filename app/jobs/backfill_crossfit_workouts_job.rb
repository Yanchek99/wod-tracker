class BackfillCrossfitWorkoutsJob < ApplicationJob
  queue_as :default

  DELAY_BETWEEN_REQUESTS = 2.seconds

  def perform(start_date, end_date)
    raise ArgumentError, 'start_date must be <= end_date' if start_date > end_date

    (start_date..end_date).each_with_index do |date, i|
      ScrapeCfWorkoutJob.set(wait: i * DELAY_BETWEEN_REQUESTS).perform_later(date)
    end
  end
end
