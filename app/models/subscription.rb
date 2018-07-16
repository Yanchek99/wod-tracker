class Subscription < ApplicationRecord
  belongs_to :program
  belongs_to :user

  validates :program, uniqueness: { scope: :user }
end
