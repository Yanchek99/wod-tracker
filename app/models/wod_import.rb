class WodImport < ApplicationRecord
  enum :status, { failed: 'failed', partial: 'partial' }

  validates :wod_date, :status, presence: true
  validates :wod_date, uniqueness: true

  # A concurrent scrape attempt for the same date can lose a find-then-insert race against
  # the unique index on wod_date; retry once so the loser updates the winner's row instead
  # of raising ActiveRecord::RecordNotUnique.
  def self.log_failure!(date, message, raw_text: nil, retries: 1)
    find_or_initialize_by(wod_date: date)
      .update!(status: :failed, raw_text: raw_text, error_message: message)
  rescue ActiveRecord::RecordNotUnique
    raise if retries.zero?

    log_failure!(date, message, raw_text: raw_text, retries: retries - 1)
  end

  # Clears a stale review-queue row once a date that previously failed has been imported
  # successfully.
  def self.clear!(date)
    find_by(wod_date: date)&.destroy
  end
end
