class WodImport < ApplicationRecord
  enum :status, { failed: 'failed', partial: 'partial' }

  validates :wod_date, :status, presence: true
  validates :wod_date, uniqueness: true
end
