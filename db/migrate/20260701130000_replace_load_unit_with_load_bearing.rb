class ReplaceLoadUnitWithLoadBearing < ActiveRecord::Migration[8.1]
  # Loads are now stored canonically in pounds, so the per-record load_unit no longer carries
  # identity or display meaning. Its one remaining job was to mark a load-bearing prescription
  # (including a find-a-max with no fixed load), which moves to an explicit load_bearing flag.
  def up
    add_column :exercises, :load_bearing, :boolean, default: false, null: false
    add_column :movement_logs, :load_bearing, :boolean, default: false, null: false

    execute 'UPDATE exercises SET load_bearing = TRUE WHERE load_unit IS NOT NULL'
    execute 'UPDATE movement_logs SET load_bearing = TRUE WHERE load_unit IS NOT NULL'

    # Loads stored in kilograms (load_unit = 1) are now interpreted as pounds, so convert their
    # magnitudes to the canonical pounds value through the source-confirmed equivalence table before
    # the unit column is gone. lb-stored loads are already canonical.
    Exercise.reset_column_information
    MovementLog.reset_column_information
    convert_kilogram_loads(Exercise, %i[load female_load male_load])
    convert_kilogram_loads(MovementLog, %i[load])

    remove_column :exercises, :load_unit
    remove_column :movement_logs, :load_unit

    # load_unit no longer participates in the content fingerprint, so existing keys are stale.
    # Recompute through the model so the fingerprint stays the single source of truth.
    Workout.reset_column_information
    Exercise.reset_column_information
    Workout.find_each { |workout| workout.update_column(:content_key, workout.content_fingerprint) } # rubocop:disable Rails/SkipsModelValidations
  end

  # read_attribute avoids the model's transient load_unit writer and reads the real column.
  def convert_kilogram_loads(model, columns)
    model.where(load_unit: 1).find_each do |record|
      updates = columns.index_with { |column| LoadEquivalence.to_lb(record.read_attribute(column), :kg) }
      record.update_columns(updates) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def down
    add_column :exercises, :load_unit, :integer
    add_column :movement_logs, :load_unit, :integer

    # Restore lb (0) as the unit for load-bearing records; kg was never stored canonically.
    execute 'UPDATE exercises SET load_unit = 0 WHERE load_bearing = TRUE'
    execute 'UPDATE movement_logs SET load_unit = 0 WHERE load_bearing = TRUE'

    remove_column :exercises, :load_bearing
    remove_column :movement_logs, :load_bearing
    # Content keys are intentionally left stale on rollback; the pre-#1684 code recomputes them from
    # load_unit on its next save, and recomputing here would run this code against the reverted schema.
  end
end
