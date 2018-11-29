class Movement < ApplicationRecord
  belongs_to :measurement, optional: true
  has_many :exercises, dependent: :destroy
  has_many :movement_logs, dependent: :destroy
end
