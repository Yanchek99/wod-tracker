# In-memory value object describing one dimension of a prescription, performance, or score.
# Exercises, movement logs, workouts, and logs build these from their own columns; nothing is
# persisted. The legacy `metrics` table this used to back was dropped once those columns were
# backfilled.
class Metric
  MEASUREMENTS = {
    calorie: 0, rep: 1, round: 2, seconds: 3,
    inch: 4, foot: 5, meter: 6,
    lb: 7, kg: 8,
    time: 9, weight: 10, height: 11, distance: 12
  }.freeze

  LOAD_MEASUREMENTS = %w[kg lb weight].freeze
  DISTANCE_MEASUREMENTS = %w[distance foot inch meter].freeze
  RECORDING_MEASUREMENT_ORDER = %w[
    rep calorie distance foot inch meter lb kg weight height seconds time round
  ].freeze

  attr_accessor :value, :female_value, :male_value
  attr_reader :measurement, :implement_count

  def self.measurements
    @measurements ||= MEASUREMENTS.stringify_keys.freeze
  end

  def self.workout_measurements
    [:calorie, :rep, :round, :time, :weight]
  end

  def self.recording_order(measurement)
    RECORDING_MEASUREMENT_ORDER.index(measurement.to_s) || RECORDING_MEASUREMENT_ORDER.length
  end

  def initialize(measurement:, value: nil, female_value: nil, male_value: nil, implement_count: nil)
    @measurement = measurement.to_s
    @value = value
    @female_value = female_value
    @male_value = male_value
    @implement_count = implement_count || 1
  end

  # Number of implements (e.g. dumbbells, kettlebells) the prescribed load is held in. The load
  # value is per-implement, so a single 50lb dumbbell and a double 50lb dumbbell share the same
  # value but differ in count.
  def multiple_implements? = implement_count > 1

  MEASUREMENTS.each_key do |name|
    define_method(:"#{name}?") { measurement == name.to_s }
  end

  def calculated_value(workout)
    return default_value unless rep?
    return calculated_rep_value(workout) if value.present?

    default_value
  end

  def default_value(user = Current.user)
    return value if value.present?
    return unless sex_specific?

    return male_value if user&.male?
    return female_value if user&.female?

    male_value.presence || female_value.presence
  end

  def sex_specific?
    female_value.present? || male_value.present?
  end

  private

  def calculated_rep_value(workout)
    # Interval ladders (e.g. 21-15-9) record total work; everything else records one round's reps.
    return value * workout.reps_from_interval if workout.interval?

    value
  end
end
