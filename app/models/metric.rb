class Metric < ApplicationRecord
  LOAD_MEASUREMENTS = %w[kg lb weight].freeze
  DISTANCE_MEASUREMENTS = %w[distance foot inch meter].freeze
  RECORDING_MEASUREMENT_ORDER = %w[
    rep calorie distance foot inch meter lb kg weight height seconds time round
  ].freeze

  belongs_to :measurable, polymorphic: true
  enum :measurement, {
    calorie: 0, rep: 1, round: 2, seconds: 3,
    inch: 4, foot: 5, meter: 6,
    lb: 7, kg: 8,
    time: 9, weight: 10, height: 11, distance: 12
  }

  validates :measurement, presence: true
  validates :measurement, uniqueness: { scope: [:measurable_id, :measurable_type] }
  validate :value_shape_is_unambiguous

  def self.workout_measurements
    [:calorie, :rep, :round, :time, :weight]
  end

  def self.recording_order(measurement)
    RECORDING_MEASUREMENT_ORDER.index(measurement.to_s) || RECORDING_MEASUREMENT_ORDER.length
  end

  def calculated_value(workout)
    rounds = workout.rounds
    return value unless rep?
    return value * workout.reps_from_interval if workout.interval?
    return nil unless value # Reps can be nil to signify max
    return value if rounds.nil? || rounds&.zero?

    value * rounds
  end

  def value=(new_value)
    super
    return unless time? && new_value.is_a?(String)

    if new_value.include? ':'
      minutes, seconds = new_value.split(':', 2)
      time_in_seconds = (minutes.to_i.minute + seconds.to_i.second).second
      super(time_in_seconds)
    else
      super(new_value.to_i)
    end
  end

  def sex_specific?
    female_value.present? || male_value.present?
  end

  private

  def value_shape_is_unambiguous
    return if value.blank? && female_value.blank? && male_value.blank?
    return if value.present? && female_value.blank? && male_value.blank?
    return if value.blank? && female_value.present? && male_value.present?

    if value.present? && sex_specific?
      errors.add(:value, 'cannot be set with male and female values')
    end

    if female_value.blank? != male_value.blank?
      errors.add(:base, 'male and female values must both be set')
    end
  end
end
