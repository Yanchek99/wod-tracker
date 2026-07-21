class Subscription < ApplicationRecord
  enum :role, { owner: 0, coach: 1, athlete: 2 }

  belongs_to :program
  belongs_to :user

  # Existing nil roles are repaired by BackfillRolelessSubscriptions before this validation matters.
  validates :role, presence: true
  validates :program, uniqueness: { scope: :user }
end
