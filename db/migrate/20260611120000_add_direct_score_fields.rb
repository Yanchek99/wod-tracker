class AddDirectScoreFields < ActiveRecord::Migration[8.1]
  class MigrationMetric < ActiveRecord::Base
    self.table_name = 'metrics'
  end

  class MigrationWorkout < ActiveRecord::Base
    self.table_name = 'workouts'
  end

  class MigrationLog < ActiveRecord::Base
    self.table_name = 'logs'
  end

  def up
    add_column :workouts, :score_type, :integer
    add_column :logs, :score_type, :integer
    add_column :logs, :score_value, :integer

    MigrationWorkout.reset_column_information
    MigrationLog.reset_column_information

    MigrationMetric.where(measurable_type: 'Workout').find_each do |metric|
      MigrationWorkout.where(id: metric.measurable_id).update_all(score_type: metric.measurement)
    end

    MigrationMetric.where(measurable_type: 'Log').find_each do |metric|
      MigrationLog.where(id: metric.measurable_id).update_all(
        score_type: metric.measurement,
        score_value: metric.value
      )
    end

    change_column_null :workouts, :score_type, false
    change_column_null :logs, :score_type, false
  end

  def down
    MigrationWorkout.reset_column_information
    MigrationLog.reset_column_information

    MigrationWorkout.where.not(score_type: nil).find_each do |workout|
      metric = MigrationMetric.where(
        measurable_type: 'Workout',
        measurable_id: workout.id
      ).first_or_initialize
      metric.measurement = workout.score_type
      metric.save!
    end

    MigrationLog.where.not(score_type: nil).find_each do |log|
      metric = MigrationMetric.where(
        measurable_type: 'Log',
        measurable_id: log.id
      ).first_or_initialize
      metric.measurement = log.score_type
      metric.value = log.score_value
      metric.save!
    end

    remove_column :logs, :score_value
    remove_column :logs, :score_type
    remove_column :workouts, :score_type
  end
end
