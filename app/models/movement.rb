class Movement < ApplicationRecord
  belongs_to :measurement
  has_many :measurables

  validates :measurement, presence: true
end
