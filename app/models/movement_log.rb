class MovementLog < ApplicationRecord
  include MovementLogPerformance

  belongs_to :log
  belongs_to :movement
  has_many :metrics, as: :measurable, dependent: :destroy

  default_scope { includes(:metrics) }
end
