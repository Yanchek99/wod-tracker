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
  validate :values_are_unambiguous

  def self.workout_measurements
    [:calorie, :rep, :round, :time, :weight]
  end

  def self.recording_order(measurement)
    RECORDING_MEASUREMENT_ORDER.index(measurement.to_s) || RECORDING_MEASUREMENT_ORDER.length
  end

  def calculated_value(workout)
    return value unless rep?

    calculated_rep_value(workout)
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

  def calculated_rep_value(workout)
    return value * workout.reps_from_interval if workout.interval?
    return value if fixed_timed_rounds?(workout)
    return nil unless value # Reps can be nil to signify max
    return value if workout.rounds.nil? || workout.rounds.zero?

    value * workout.rounds
  end

  def fixed_timed_rounds?(workout)
    workout.timed_rounds? && !workout.emom?
  end

  def values_are_unambiguous
    return if valid_value_combination?

    errors.add(:value, 'cannot be set with male and female values') if mixes_unisex_and_sex_specific_values?
    errors.add(:base, 'male and female values must both be set') if missing_paired_sex_specific_value?
  end

  def valid_value_combination?
    no_values? || unisex_value_only? || paired_sex_specific_values_only?
  end

  def no_values?
    value.blank? && female_value.blank? && male_value.blank?
  end

  def unisex_value_only?
    value.present? && female_value.blank? && male_value.blank?
  end

  def paired_sex_specific_values_only?
    value.blank? && female_value.present? && male_value.present?
  end

  def mixes_unisex_and_sex_specific_values?
    value.present? && sex_specific?
  end

  def missing_paired_sex_specific_value?
    female_value.blank? != male_value.blank?
  end
end
