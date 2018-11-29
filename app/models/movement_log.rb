class MovementLog < ApplicationRecord
  belongs_to :log
  belongs_to :movement
  has_many :metrics, as: :measurable, dependent: :destroy

  default_scope { includes(:metrics) }

  accepts_nested_attributes_for :metrics, allow_destroy: true

  validates :log, presence: true
end
