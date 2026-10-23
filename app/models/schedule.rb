class Schedule < ApplicationRecord
  belongs_to :program
  belongs_to :workout

  validates :posted_at, presence: true

  scope :posted_dates, -> { order(posted_at: :desc).select(:posted_at).distinct }
end
