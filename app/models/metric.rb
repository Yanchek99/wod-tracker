class Metric < ApplicationRecord
  belongs_to :exercise
  enum measurement: { rep: 'rep',  calorie: 'calorie', distance: 'distance' }

  validates :exercise, :measurement, :value, presence: true
end
