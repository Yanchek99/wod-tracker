class MovementLog < ApplicationRecord
  belongs_to :log
  belongs_to :movement

  validates :log, :movement, :measurement_value, presence: true
end
