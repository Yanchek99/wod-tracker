class Movement < ApplicationRecord
  has_many :exercises, dependent: :destroy
  has_many :movement_logs, dependent: :destroy
end
