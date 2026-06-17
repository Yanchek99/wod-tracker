class MovementLog < ApplicationRecord
  include MovementLogPerformance

  belongs_to :log
  belongs_to :movement
end
