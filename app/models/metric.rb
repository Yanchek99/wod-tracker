class Metric < ApplicationRecord
  belongs_to :exercise
  enum measurement: { rep: 'rep',  calorie: 'calorie', distance: 'distance', time: 'time', weight: 'weight' }

  validates :exercise, :measurement, :value, presence: true
  validates :measurement, uniqueness: { scope: :exercise }
end
