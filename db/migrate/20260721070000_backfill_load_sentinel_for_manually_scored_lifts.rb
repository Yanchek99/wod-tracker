class BackfillLoadSentinelForManuallyScoredLifts < ActiveRecord::Migration[8.1]
  # Workouts where the athlete's score is a single weight typed once (score_measurement == 'weight'
  # && !calculated_lifting_score?), so the score never derives from any one movement -- but these
  # exercises were seeded with load: nil instead of the load: 0 "unspecified load" sentinel this app
  # uses elsewhere (e.g. Gwen), so Exercise#load_bearing? was false and Log#backfill_lifting_loads_from_score
  # had nothing to attach the score to. See issue #1783.
  AFFECTED_PAIRS = [
    ['Open 15.1a', 'Clean and Jerk'],
    ['Open 18.2a', 'Clean'],
    ['Open 21.4', 'Deadlift'],
    ['Open 21.4', 'Clean'],
    ['Open 21.4', 'Hang Clean'],
    ['Open 21.4', 'Jerk'],
    ['Open 23.2B', 'Thruster']
  ].freeze

  class MigrationWorkout < ActiveRecord::Base
    self.table_name = 'workouts'
  end

  class MigrationMovement < ActiveRecord::Base
    self.table_name = 'movements'
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
    say_with_time "Backfilling load: 0 sentinel for #{AFFECTED_PAIRS.size} manually-scored lift exercises" do
      AFFECTED_PAIRS.each { |workout_name, movement_name| backfill_pair(workout_name, movement_name) }
    end
  end

  def down
    say 'Data-only migration -- cannot distinguish originally-nil load from the sentinel #up set. No-op.'
  end

  private

  def backfill_pair(workout_name, movement_name)
    workout = MigrationWorkout.find_by(name: workout_name)
    raise "Workout not found: #{workout_name}" unless workout

    movement = MigrationMovement.find_by(name: movement_name)
    raise "Movement not found: #{movement_name}" unless movement

    segment_ids = MigrationSegment.where(workout_id: workout.id).pluck(:id)
    exercises = MigrationExercise.where(segment_id: segment_ids, movement_id: movement.id)
    raise "No exercise found for #{workout_name} / #{movement_name}" if exercises.none?

    exercises.each { |exercise| exercise.update!(load: 0) }
  end
end
