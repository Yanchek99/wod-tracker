class Metric < ApplicationRecord
  belongs_to :exercise
  belongs_to :measurement

  validates :exercise, :measurement, :value, presence: true
end
