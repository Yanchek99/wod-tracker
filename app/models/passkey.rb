class Passkey < ApplicationRecord
  belongs_to :user

  validates :external_id, :public_key, :label, presence: true
  validates :external_id, uniqueness: true
end
