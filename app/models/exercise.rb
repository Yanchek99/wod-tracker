class Exercise < ApplicationRecord
  belongs_to :workout
  belongs_to :movement
  belongs_to :measurement, optional: true
  has_many :metrics, as: :measurable, dependent: :destroy

  default_scope { includes(:metrics) }

  accepts_nested_attributes_for :metrics, allow_destroy: true
end
