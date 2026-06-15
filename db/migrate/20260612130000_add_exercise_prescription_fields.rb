class AddExercisePrescriptionFields < ActiveRecord::Migration[8.1]
  # Mirrors Metric.measurements so the backfill can read legacy rows without the model.
  CALORIE = 0
  REP = 1
  ROUND = 2
  SECONDS = 3
  INCH = 4
  FOOT = 5
  METER = 6
  LB = 7
  KG = 8
  TIME = 9
  WEIGHT = 10
  HEIGHT = 11
  DISTANCE = 12

  # Exercise enum ints (the enums themselves are declared on the model in a later phase).
  LOAD_UNITS = { lb: 0, kg: 1 }.freeze
  DISTANCE_UNITS = { meter: 0, foot: 1, inch: 2 }.freeze

  PRESCRIPTION_COLUMNS = %i[
    reps duration_seconds
    load female_load male_load load_unit
    distance female_distance male_distance distance_unit
    calories female_calories male_calories
    notes
  ].freeze

  class MigrationMetric < ActiveRecord::Base
    self.table_name = 'metrics'
  end

  class MigrationExercise < ActiveRecord::Base
    self.table_name = 'exercises'
  end

  class MigrationWorkout < ActiveRecord::Base
    self.table_name = 'workouts'
  end

  def up
    add_column :exercises, :reps, :integer
    add_column :exercises, :duration_seconds, :integer
    add_column :exercises, :load, :integer
    add_column :exercises, :female_load, :integer
    add_column :exercises, :male_load, :integer
    add_column :exercises, :load_unit, :integer
    add_column :exercises, :distance, :integer
    add_column :exercises, :female_distance, :integer
    add_column :exercises, :male_distance, :integer
    add_column :exercises, :distance_unit, :integer
    add_column :exercises, :calories, :integer
    add_column :exercises, :female_calories, :integer
    add_column :exercises, :male_calories, :integer
    add_column :exercises, :notes, :string

    MigrationExercise.reset_column_information
    backfill
  end

  def down
    PRESCRIPTION_COLUMNS.each { |column| remove_column :exercises, column }
  end

  private

  def backfill
    workout_names = MigrationWorkout.pluck(:id, :name).to_h
    mapped = 0
    notes = 0
    unmapped = 0

    metrics_by_exercise = MigrationMetric.where(measurable_type: 'Exercise').group_by(&:measurable_id)
    metrics_by_exercise.each do |exercise_id, metrics|
      exercise = MigrationExercise.find_by(id: exercise_id)
      next unless exercise

      attrs = {}
      filled = []

      metrics.sort_by(&:id).each do |metric|
        status, reason = apply_metric(metric, attrs, filled)
        case status
        when :note then mapped += 1; notes += 1
        when :mapped then mapped += 1
        when :unmapped then unmapped += 1
        end
        audit(status, reason, metric, exercise_id, workout_names[exercise.workout_id]) if reason
      end

      MigrationExercise.where(id: exercise_id).update_all(attrs) if attrs.any?
    end

    say "Backfill: #{mapped} mapped, #{notes} notes, #{unmapped} unmapped"
  end

  # Returns [status, reason]. status is :mapped, :note, or :unmapped; reason is nil unless audited.
  def apply_metric(metric, attrs, filled)
    case metric.measurement
    when REP then apply_reps(metric, attrs, filled)
    when CALORIE then apply_calories(metric, attrs, filled)
    when SECONDS, TIME then apply_duration(metric, attrs, filled)
    when LB, KG, WEIGHT then apply_load(metric, attrs, filled)
    when METER, FOOT, INCH, DISTANCE, HEIGHT then apply_distance(metric, attrs, filled)
    else
      [:unmapped, "unexpected measurement #{metric.measurement}"]
    end
  end

  def apply_reps(metric, attrs, filled)
    return [:unmapped, 'sex-specific reps unsupported'] if sex_specific?(metric)
    return [:unmapped, 'duplicate reps'] if filled.include?(:reps)

    filled << :reps
    attrs[:reps] = metric.value || 0 # blank rep metric means "max reps"
    [:mapped, nil]
  end

  def apply_calories(metric, attrs, filled)
    return [:unmapped, 'duplicate calories'] if filled.include?(:calories)

    filled << :calories
    if positive?(metric.value)
      attrs[:calories] = metric.value
    elsif sex_specific?(metric)
      attrs[:female_calories] = metric.female_value if positive?(metric.female_value)
      attrs[:male_calories] = metric.male_value if positive?(metric.male_value)
    else
      attrs[:calories] = 0 # blank calorie metric means "max calories"
    end
    [:mapped, nil]
  end

  def apply_duration(metric, attrs, filled)
    return [:unmapped, 'duplicate duration'] if filled.include?(:duration)

    filled << :duration
    attrs[:duration_seconds] = metric.value if positive?(metric.value)
    [:mapped, nil]
  end

  def apply_load(metric, attrs, filled)
    return [:unmapped, 'duplicate load'] if filled.include?(:load)

    filled << :load
    attrs[:load_unit] = LOAD_UNITS[metric.measurement == KG ? :kg : :lb]
    attrs[:load] = metric.value if positive?(metric.value)
    attrs[:female_load] = metric.female_value if positive?(metric.female_value)
    attrs[:male_load] = metric.male_value if positive?(metric.male_value)

    return [:note, 'implicit unit assumed lb — verify; possible bodyweight artifact'] if metric.measurement == WEIGHT

    [:mapped, nil]
  end

  def apply_distance(metric, attrs, filled)
    return [:unmapped, 'duplicate length'] if filled.include?(:distance)

    filled << :distance
    unit = distance_unit_for(metric.measurement)
    attrs[:distance_unit] = DISTANCE_UNITS[unit] if unit
    attrs[:distance] = metric.value if positive?(metric.value)
    attrs[:female_distance] = metric.female_value if positive?(metric.female_value)
    attrs[:male_distance] = metric.male_value if positive?(metric.male_value)

    return [:note, 'unitless height enum mapped to distance'] if metric.measurement == HEIGHT

    [:mapped, nil]
  end

  def distance_unit_for(measurement)
    case measurement
    when METER then :meter
    when FOOT then :foot
    when INCH then :inch
    end # DISTANCE and HEIGHT have no unit
  end

  def audit(status, reason, metric, exercise_id, workout_name)
    label = status == :unmapped ? 'UNMAPPED' : 'NOTE'
    say "#{label} metric ##{metric.id} (exercise ##{exercise_id}, workout '#{workout_name}'): " \
        "measurement=#{metric.measurement} value=#{metric.value.inspect} " \
        "female=#{metric.female_value.inspect} male=#{metric.male_value.inspect} — #{reason}"
  end

  def sex_specific?(metric)
    metric.female_value.present? || metric.male_value.present?
  end

  def positive?(value)
    value.is_a?(Integer) && value.positive?
  end
end
