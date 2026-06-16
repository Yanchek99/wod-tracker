class AddMovementLogPerformanceFields < ActiveRecord::Migration[8.1]
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

  # MovementLog enum ints (the enums themselves are declared on the model).
  LOAD_UNITS = { lb: 0, kg: 1 }.freeze
  DISTANCE_UNITS = { meter: 0, foot: 1, inch: 2 }.freeze

  PERFORMANCE_COLUMNS = %i[
    reps duration_seconds load load_unit distance distance_unit calories notes
  ].freeze

  class MigrationMetric < ActiveRecord::Base
    self.table_name = 'metrics'
  end

  class MigrationMovementLog < ActiveRecord::Base
    self.table_name = 'movement_logs'
  end

  def up
    add_column :movement_logs, :reps, :integer
    add_column :movement_logs, :duration_seconds, :integer
    add_column :movement_logs, :load, :integer
    add_column :movement_logs, :load_unit, :integer
    add_column :movement_logs, :distance, :integer
    add_column :movement_logs, :distance_unit, :integer
    add_column :movement_logs, :calories, :integer
    add_column :movement_logs, :notes, :string

    MigrationMovementLog.reset_column_information
    backfill
  end

  def down
    PERFORMANCE_COLUMNS.each { |column| remove_column :movement_logs, column }
  end

  private

  def backfill
    mapped = 0
    unmapped = 0

    metrics_by_log = MigrationMetric.where(measurable_type: 'MovementLog').group_by(&:measurable_id)
    metrics_by_log.each do |movement_log_id, metrics|
      next unless MigrationMovementLog.exists?(id: movement_log_id)

      attrs = {}
      filled = []
      metrics.sort_by(&:id).each do |metric|
        if apply_metric(metric, attrs, filled)
          mapped += 1
        else
          unmapped += 1
          say "UNMAPPED metric ##{metric.id} (movement_log ##{movement_log_id}): " \
              "measurement=#{metric.measurement} value=#{metric.value.inspect}"
        end
      end

      MigrationMovementLog.where(id: movement_log_id).update_all(attrs) if attrs.any?
    end

    say "Backfill: #{mapped} mapped, #{unmapped} unmapped"
  end

  # Returns true when the metric mapped to a column, false when left in place (audited).
  def apply_metric(metric, attrs, filled)
    case metric.measurement
    when REP then fill(attrs, filled, :reps) { attrs[:reps] = metric.value if positive?(metric.value) }
    when SECONDS, TIME then fill(attrs, filled, :duration) { attrs[:duration_seconds] = metric.value if positive?(metric.value) }
    when LB, KG, WEIGHT then fill(attrs, filled, :load) { fill_load(metric, attrs) }
    when METER, FOOT, INCH, DISTANCE, HEIGHT then fill(attrs, filled, :distance) { fill_distance(metric, attrs) }
    when CALORIE then fill(attrs, filled, :calories) { attrs[:calories] = metric.value if positive?(metric.value) }
    else false
    end
  end

  def fill(_attrs, filled, dimension)
    return false if filled.include?(dimension)

    filled << dimension
    yield
    true
  end

  def fill_load(metric, attrs)
    attrs[:load_unit] = LOAD_UNITS[metric.measurement == KG ? :kg : :lb]
    attrs[:load] = metric.value if positive?(metric.value)
  end

  def fill_distance(metric, attrs)
    unit = { METER => :meter, FOOT => :foot, INCH => :inch }[metric.measurement]
    attrs[:distance_unit] = DISTANCE_UNITS[unit] if unit
    attrs[:distance] = metric.value if positive?(metric.value)
  end

  def positive?(value)
    value.is_a?(Integer) && value.positive?
  end
end
