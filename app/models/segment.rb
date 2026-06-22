class Segment < ApplicationRecord
  belongs_to :workout
  has_many :exercises, dependent: :destroy

  accepts_nested_attributes_for :exercises, allow_destroy: true

  default_scope { order(:position).includes(:exercises) }

  before_validation :assign_position, if: -> { position.blank? }

  validates :position, presence: true,
                       numericality: { only_integer: true, greater_than: 0 },
                       uniqueness: { scope: :workout_id }
  validate :position_unique_within_workout_parts

  def rounds?
    rounds.present? && time_seconds.blank? && interval_scheme.blank?
  end

  def amrap?
    time_seconds.present? && rounds.blank? && interval_scheme.blank?
  end

  def max_reps?
    amrap? && exercises.any? { |exercise| exercise.reps&.zero? }
  end

  def emom?
    time_seconds.present? && rounds.present? && (time_seconds % (60 * rounds)).zero?
  end

  def timed_rounds?
    rounds.present? && time_seconds.present? && interval_scheme.nil?
  end

  def interval?
    interval_scheme.present?
  end

  def reps_from_interval
    return nil unless interval?

    interval_scheme.split('-').sum(&:to_i)
  end

  # Time is a number of seconds or a string in the format "Minutes:Seconds" or "Hours:Minutes:Seconds"
  def time_seconds=(value)
    if value.is_a?(String) && value.include?(':')
      parts = value.split(':').map(&:to_i)
      super(parts.reverse.each_with_index.sum { |part, index| part * (60**index) })
    else
      super
    end
  end

  private

  def assign_position
    return if workout.blank?

    self.position = next_workout_part_position
  end

  def next_workout_part_position
    positions = workout_part_positions
    positions << persisted_workout_part_position

    positions.compact.max.to_i + 1
  end

  def workout_part_positions
    top_level_exercise_positions + segment_positions
  end

  def top_level_exercise_positions
    workout.exercises.filter_map do |exercise|
      exercise.position if exercise.segment.blank? && !exercise.marked_for_destruction?
    end
  end

  def segment_positions
    workout.segments.filter_map do |segment|
      segment.position if segment != self && !segment.marked_for_destruction?
    end
  end

  def persisted_workout_part_position
    return if workout_id.blank?

    [
      Exercise.unscoped.where(workout_id:, segment_id: nil).maximum(:position),
      Segment.unscoped.where(workout_id:).where.not(id:).maximum(:position)
    ].compact.max
  end

  def position_unique_within_workout_parts
    return if position.blank?

    errors.add(:position, 'has already been taken') if duplicate_workout_part_position?
  end

  def duplicate_workout_part_position?
    duplicate_top_level_exercise_position? || unsaved_segment_position_exists?
  end

  def duplicate_top_level_exercise_position?
    persisted_top_level_exercise_position_exists? || unsaved_top_level_exercise_position_exists?
  end

  def persisted_top_level_exercise_position_exists?
    return false if workout_id.blank?

    Exercise.unscoped.exists?(workout_id:, segment_id: nil, position:)
  end

  def unsaved_top_level_exercise_position_exists?
    return false if workout.blank?

    workout.exercises.any? do |exercise|
      exercise.segment.blank? && exercise.position == position && !exercise.marked_for_destruction?
    end
  end

  def unsaved_segment_position_exists?
    return false if workout.blank?

    workout.segments.any? do |segment|
      segment != self && segment.position == position && !segment.marked_for_destruction?
    end
  end
end
