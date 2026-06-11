class AddDirectScoreFieldsToWorkoutsAndLogs < ActiveRecord::Migration[8.1]
  def up
    add_column :workouts, :score_type, :integer
    add_column :logs, :score_type, :integer
    add_column :logs, :score_value, :integer

    execute <<~SQL.squish
      UPDATE workouts
      SET score_type = metrics.measurement
      FROM metrics
      WHERE metrics.measurable_type = 'Workout'
        AND metrics.measurable_id = workouts.id
    SQL

    execute <<~SQL.squish
      UPDATE logs
      SET score_type = metrics.measurement,
          score_value = metrics.value
      FROM metrics
      WHERE metrics.measurable_type = 'Log'
        AND metrics.measurable_id = logs.id
    SQL
  end

  def down
    remove_column :logs, :score_value
    remove_column :logs, :score_type
    remove_column :workouts, :score_type
  end
end
