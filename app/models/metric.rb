class Metric < ApplicationRecord
  belongs_to :measurable, polymorphic: true
  enum :measurement, {
    calorie: 0, rep: 1, round: 2, seconds: 3,
    inch: 4, foot: 5, meter: 6,
    lb: 7, kg: 8,
    time: 9, weight: 10, height: 11, distance: 12
  }

  validates :measurement, presence: true
  validates :measurement, uniqueness: { scope: [:measurable_id, :measurable_type] }

  def self.workout_measurements
    [:calorie, :rep, :round, :time, :weight]
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
end
