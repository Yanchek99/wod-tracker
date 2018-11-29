class Metric < ApplicationRecord
  belongs_to :measurable, polymorphic: true
  enum measurement: { calorie: 'calorie', distance: 'distance', height: 'height', rep: 'rep', round: 'round', time: 'time', weight: 'weight' }

  validates :measurable, :measurement, presence: true
  validates :measurement, uniqueness: { scope: :measurable }

  UNITS = { weight: 'lb', distance: 'meter', time: 'second', height: 'inch' }.freeze

  def unit
    return UNITS.fetch(measurement.to_sym) if UNITS.key?(measurement.to_sym)

    measurement
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
    super(new_value)
    return unless time? && new_value.is_a?(String)

    if new_value.include? ':'
      minutes, seconds = new_value.split(':', 2)
      time_in_seconds = (minutes.to_i.minute + seconds.to_i.second).second
      super(time_in_seconds)
    else
      super(new_value.to_i)
    end
  end
end
