class Exercise < ApplicationRecord
  belongs_to :workout
  belongs_to :movement
  belongs_to :measurement, optional: true
  belongs_to :segment, optional: true
  has_many :metrics, as: :measurable, dependent: :destroy

  default_scope { includes(:metrics) }

  accepts_nested_attributes_for :metrics, allow_destroy: true

  before_validation :set_workout_from_segment

  private

  def set_workout_from_segment
    self.workout = segment.workout if segment
  end
end
