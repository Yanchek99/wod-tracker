class MovementLog < ApplicationRecord
  belongs_to :log
  belongs_to :movement
  belongs_to :measurement, optional: true
  has_many :metrics, as: :measurable, dependent: :destroy

  accepts_nested_attributes_for :metrics, allow_destroy: true

  validates :log, presence: true
end
