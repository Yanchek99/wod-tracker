module ExercisePositionValidation
  extend ActiveSupport::Concern

  included do
    before_validation :set_workout_from_segment

    validates :position, presence: true,
                         numericality: { only_integer: true, greater_than: 0 },
                         uniqueness: { scope: :workout_id,
                                       conditions: -> { where(segment_id: nil) },
                                       if: :top_level? }
    validate :position_unique_within_segment, if: :segment
    validate :position_unique_within_workout_parts, if: :top_level?
  end

  private

  def set_workout_from_segment
    self.workout = segment.workout if segment
  end

  def top_level?
    segment.blank?
  end

  def position_unique_within_segment
    return if position.blank?

    errors.add(:position, 'has already been taken') if duplicate_segment_position?
  end

  def position_unique_within_workout_parts
    return if position.blank?

    errors.add(:position, 'has already been taken') if duplicate_segment_part_position?
  end

  def duplicate_segment_position?
    persisted_segment_position_exists? || unsaved_segment_position_exists?
  end

  def duplicate_segment_part_position?
    persisted_segment_part_position_exists? || unsaved_segment_part_position_exists?
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
    candidates = segment ? segment.exercises.to_a : []
    candidates += workout.exercises.to_a if workout

    candidates.select do |exercise|
      exercise != self && exercise.segment == segment && !exercise.marked_for_destruction?
    end
  end

  def persisted_segment_part_position_exists?
    return false if workout_id.blank?

    Segment.unscoped.exists?(workout_id:, position:)
  end

  def unsaved_segment_part_position_exists?
    return false if workout.blank?

    workout.segments.any? do |segment|
      segment.position == position && !segment.marked_for_destruction?
    end
  end
end
