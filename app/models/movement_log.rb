class MovementLog < ApplicationRecord
  belongs_to :log
  belongs_to :movement
end
