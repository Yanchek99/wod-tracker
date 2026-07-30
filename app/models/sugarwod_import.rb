class SugarwodImport < ApplicationRecord
  enum :status, { pending: 'pending', completed: 'completed' }

  belongs_to :user

  validates :status, presence: true
end
