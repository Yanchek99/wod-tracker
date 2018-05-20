class MovementLog < ApplicationRecord
  belongs_to :log
  belongs_to :movement
  belongs_to :measurement

  validates :log, :movement, :measurement, :measurement_value, presence: true
end
