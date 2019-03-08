class Subscription < ApplicationRecord
  enum role: { owner: 'owner', coach: 'coach', athlete: 'athelete' }

  belongs_to :program
  belongs_to :user

  validates :program, uniqueness: { scope: :user }
end
