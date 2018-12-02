class Schedule < ApplicationRecord
  belongs_to :program
  belongs_to :workout

  scope :posted_dates, -> { order(posted_at: :desc).select(:posted_at).distint }
end
