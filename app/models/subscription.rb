class Subscription < ApplicationRecord
  enum :role, { owner: 0, coach: 1, athlete: 2 }

  belongs_to :program
  belongs_to :user

  validates :program, uniqueness: { scope: :user }
end
