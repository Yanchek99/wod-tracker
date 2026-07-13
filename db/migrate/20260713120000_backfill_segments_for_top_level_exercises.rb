class BackfillSegmentsForTopLevelExercises < ActiveRecord::Migration[8.1]
  class MigrationWorkout < ActiveRecord::Base
    self.table_name = 'workouts'
  end

  class MigrationSegment < ActiveRecord::Base
    self.table_name = 'segments'
    self.record_timestamps = false
  end

  class MigrationExercise < ActiveRecord::Base
    self.table_name = 'exercises'
    self.record_timestamps = false
  end

  def up
    workout_ids = MigrationExercise.where(segment_id: nil).distinct.pluck(:workout_id)

    say_with_time "Backfilling implicit segments for #{workout_ids.size} workouts" do
      workout_ids.each { |workout_id| backfill_workout(workout_id) }
    end
  end

  def down
    say 'Data-only migration -- implicit segments created by #up are not restorable to top-level exercises. No-op.'
  end

  private

  def backfill_workout(workout_id)
    workout = MigrationWorkout.find(workout_id)
    exercise_runs = exercise_runs(workout_id)
    scheme = workout_scheme(workout)
    reject_ambiguous_runs!(workout, exercise_runs, scheme)
    exercise_runs.each { |run| wrap_run(workout, run, scheme) }
    Workout.find(workout_id).refresh_content_key!
  end

  def ordered_parts(workout_id)
    (MigrationExercise.where(workout_id:, segment_id: nil).to_a + MigrationSegment.where(workout_id:).to_a)
      .sort_by { |part| [part.position, part.id] }
  end

  def exercise_runs(workout_id)
    ordered_parts(workout_id)
      .chunk_while { |left, right| left.is_a?(MigrationExercise) && right.is_a?(MigrationExercise) }
      .select { |run| run.first.is_a?(MigrationExercise) }
  end

  def reject_ambiguous_runs!(workout, exercise_runs, scheme)
    return unless exercise_runs.size > 1 && scheme

    raise "Workout #{workout.id} has #{exercise_runs.size} top-level exercise runs with rounds=#{workout.rounds.inspect}, " \
          "time=#{workout.time.inspect}, interval=#{workout.interval.inspect}"
  end

  def workout_scheme(workout)
    return if workout.rounds.to_i <= 1 && workout.time.blank? && workout.interval.blank?

    {
      rounds: (workout.rounds if workout.rounds.to_i > 1),
      time_seconds: (workout.time * 60 if workout.time.present?),
      interval_scheme: workout.interval
    }.compact
  end

  def wrap_run(workout, run, scheme)
    segment = MigrationSegment.create!(
      {
        workout_id: workout.id,
        position: run.first.position,
        created_at: Time.current,
        updated_at: Time.current
      }.merge(scheme || {})
    )

    run.each_with_index do |exercise, index|
      exercise.update!(segment_id: segment.id, position: index + 1)
    end
  end
end
