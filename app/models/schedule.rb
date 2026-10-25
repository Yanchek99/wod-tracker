class Schedule < ApplicationRecord
  belongs_to :program
  belongs_to :workout

  validates :posted_at, presence: true

  # Schedules are anchored to 6pm Pacific, so "posted" means up to the end of today's Pacific calendar day;
  # cutting off at the current instant would hide today's workout until that evening.
  scope :posted_through_today, -> { where(posted_at: ..SchedulesController::POSTED_AT_ZONE.now.end_of_day) }

  scope :posted_dates, -> { order(posted_at: :desc).select(:posted_at).distinct }
end
