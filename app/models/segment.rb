class Segment < ApplicationRecord
  include ImplicitWorkoutPart
  include RefreshesWorkoutContentKey

  belongs_to :workout
  has_many :exercises, dependent: :destroy

  accepts_nested_attributes_for :exercises, allow_destroy: true

  default_scope { order(:position).includes(:exercises) }

  before_validation :assign_position, if: -> { position.blank? }

  validates :position, presence: true,
                       numericality: { only_integer: true, greater_than: 0 },
                       uniqueness: { scope: :workout_id }
  validate :position_unique_within_workout_parts

  def schemed?
    rounds.present? || time_seconds.present? || interval_scheme.present?
  end

  def rounds?
    rounds.present? && time_seconds.blank? && interval_scheme.blank?
  end

  def amrap?
    time_seconds.present? && rounds.blank? && interval_scheme.blank?
  end

  def max_reps?
    # A prescribed rep count of 0 is the app's "max reps" sentinel.
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

    self.position = next_segment_position
  end

  def next_segment_position
    positions = segment_positions
    positions << persisted_segment_position

    positions.compact.max.to_i + 1
  end

  def segment_positions
    workout.segments.filter_map do |segment|
      segment.position if segment != self && !segment.marked_for_destruction?
    end
  end

  def persisted_segment_position
    return if workout_id.blank?

    Segment.unscoped.where(workout_id:).where.not(id:).maximum(:position)
  end

  def position_unique_within_workout_parts
    return if position.blank?

    errors.add(:position, 'has already been taken') if unsaved_segment_position_exists?
  end

  def unsaved_segment_position_exists?
    return false if workout.blank?

    workout.segments.any? do |segment|
      segment != self && segment.position == position && !segment.marked_for_destruction?
    end
  end
end
