module ExercisePositionValidation
  extend ActiveSupport::Concern

  included do
    before_validation :set_workout_from_segment

    validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validate :position_unique_within_segment
  end

  private

  def set_workout_from_segment
    self.workout = segment.workout if segment
  end

  def position_unique_within_segment
    return if position.blank? || segment.blank?

    errors.add(:position, 'has already been taken') if duplicate_segment_position?
  end

  def duplicate_segment_position?
    persisted_segment_position_exists? || unsaved_segment_position_exists?
  end

  def persisted_segment_position_exists?
    return false if segment_id.blank?

    duplicate = Exercise.unscoped.where(segment_id:, position:)
    duplicate = duplicate.where.not(id:) if id.present?

    duplicate.exists?
  end

  def unsaved_segment_position_exists?
    unsaved_segment_siblings.any? { |exercise| exercise.position == position }
  end

  def unsaved_segment_siblings
    segment.exercises.to_a.select { |exercise| exercise != self && !exercise.marked_for_destruction? }
  end
end
