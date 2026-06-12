class AddDirectScoreFields < ActiveRecord::Migration[8.1]
  # Mirrors Metric.measurements for rows that have no legacy score metric
  ROUND_SCORE = 2
  TIME_SCORE = 9

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

    backfill_workouts_from_metrics
    backfill_logs_from_metrics
    backfill_workouts_without_score_metric
    backfill_logs_without_score_metric

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

  private

  def backfill_workouts_from_metrics
    MigrationMetric.where(measurable_type: 'Workout').find_each do |metric|
      MigrationWorkout.where(id: metric.measurable_id).update_all(score_type: metric.measurement)
    end
  end

  def backfill_logs_from_metrics
    MigrationMetric.where(measurable_type: 'Log').find_each do |metric|
      MigrationLog.where(id: metric.measurable_id).update_all(
        score_type: metric.measurement,
        score_value: metric.value
      )
    end
  end

  def backfill_workouts_without_score_metric
    MigrationWorkout
      .where(score_type: nil, rounds: nil, interval: nil)
      .where.not(time: nil)
      .update_all(score_type: ROUND_SCORE)
    MigrationWorkout.where(score_type: nil).update_all(score_type: TIME_SCORE)
  end

  def backfill_logs_without_score_metric
    MigrationLog.where(score_type: nil).find_each do |log|
      workout_score = MigrationWorkout.where(id: log.workout_id).pick(:score_type)
      MigrationLog.where(id: log.id).update_all(score_type: workout_score || TIME_SCORE)
    end
  end
end
