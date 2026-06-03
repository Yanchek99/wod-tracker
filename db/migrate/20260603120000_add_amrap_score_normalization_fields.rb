class AddAmrapScoreNormalizationFields < ActiveRecord::Migration[8.0]
  class MigrationExercise < ActiveRecord::Base
    self.table_name = 'exercises'

    belongs_to :workout, class_name: 'AddAmrapScoreNormalizationFields::MigrationWorkout', foreign_key: :workout_id
    has_many :metrics, as: :measurable, class_name: 'AddAmrapScoreNormalizationFields::MigrationMetric'

    default_scope { order(:position) }

    def scoring_reps
      calorie = metrics.find { |metric| metric.measurement == 'calorie' }
      return calorie.value if positive_value?(calorie)

      rep = metrics.find { |metric| metric.measurement == 'rep' }
      return rep.value if positive_value?(rep)

      nil
    end

    private

    def positive_value?(metric)
      metric&.value.present? && metric.value.positive?
    end
  end

  class MigrationLog < ActiveRecord::Base
    self.table_name = 'logs'

    belongs_to :workout, class_name: 'AddAmrapScoreNormalizationFields::MigrationWorkout', foreign_key: :workout_id
    has_one :metric, as: :measurable, class_name: 'AddAmrapScoreNormalizationFields::MigrationMetric'
  end

  class MigrationMetric < ActiveRecord::Base
    self.table_name = 'metrics'

    belongs_to :measurable, polymorphic: true

    enum :measurement, {
      calorie: 0, rep: 1, round: 2, seconds: 3,
      inch: 4, foot: 5, meter: 6,
      lb: 7, kg: 8,
      time: 9, weight: 10, height: 11, distance: 12
    }
  end

  class MigrationWorkout < ActiveRecord::Base
    self.table_name = 'workouts'

    has_one :metric, as: :measurable, class_name: 'AddAmrapScoreNormalizationFields::MigrationMetric'
    has_many :exercises, class_name: 'AddAmrapScoreNormalizationFields::MigrationExercise', foreign_key: :workout_id
    has_many :logs, class_name: 'AddAmrapScoreNormalizationFields::MigrationLog', foreign_key: :workout_id

    def amrap?
      time.present? && rounds.blank? && interval.blank?
    end

    def reps_per_round
      scored_exercises = exercises.select { |exercise| exercise.segment_id.nil? }
      return nil if scored_exercises.empty?

      scored_exercises.sum do |exercise|
        reps = exercise.scoring_reps
        return nil unless reps

        reps
      end
    end
  end

  def up
    add_column :exercises, :distance_units_per_rep, :integer
    add_column :logs, :reps_per_round, :integer

    converted = []
    snapshotted = []
    ambiguous = []

    MigrationWorkout.includes(:metric, :exercises, logs: :metric).find_each do |workout|
      next unless workout.amrap?

      reps_per_round = workout.reps_per_round

      if workout.metric&.round?
        if reps_per_round
          workout.metric.update!(measurement: :rep)
          workout.logs.each do |log|
            next unless log.metric&.round?

            log.metric.update!(measurement: :rep, value: log.metric.value.to_i * reps_per_round)
            log.update!(reps_per_round: reps_per_round)
          end
          converted << workout.id
        else
          ambiguous << workout.id
        end
      elsif workout.metric&.rep? && reps_per_round
        workout.logs.each do |log|
          next unless log.metric&.rep?

          log.update!(reps_per_round: reps_per_round)
        end
        snapshotted << workout.id
      end
    end

    say "Converted round-scored AMRAP workouts to reps: #{converted.join(', ')}" if converted.any?
    say "Snapshotted reps_per_round for AMRAP workouts: #{snapshotted.join(', ')}" if snapshotted.any?
    say "AMRAP workouts needing manual score review: #{ambiguous.join(', ')}" if ambiguous.any?
  end

  def down
    remove_column :logs, :reps_per_round
    remove_column :exercises, :distance_units_per_rep
  end
end
