class Exercise < ApplicationRecord
  belongs_to :workout
  belongs_to :movement
  belongs_to :segment, optional: true
  has_many :metrics, as: :measurable, dependent: :destroy

  default_scope { order(:position).includes(:metrics) }

  accepts_nested_attributes_for :metrics, allow_destroy: true

  before_validation :set_workout_from_segment

  validates :position, presence: true,
                       numericality: { only_integer: true, greater_than: 0 },
                       uniqueness: { scope: :workout }

  private

  def set_workout_from_segment
    self.workout = segment.workout if segment
  end
end
