class BackfillLoadSentinelForManuallyScoredLifts < ActiveRecord::Migration[8.1]
  AFFECTED_PAIRS = [
    [ 'Open 15.1a', 'Clean and Jerk' ],
    [ 'Open 18.2a', 'Clean' ],
    [ 'Open 21.4', 'Deadlift' ],
    [ 'Open 21.4', 'Clean' ],
    [ 'Open 21.4', 'Hang Clean' ],
    [ 'Open 21.4', 'Jerk' ],
    [ 'Open 23.2B', 'Thruster' ]
  ].freeze

  class MigrationWorkout < ActiveRecord::Base
    self.table_name = 'workouts'
  end

  class MigrationMovement < ActiveRecord::Base
    self.table_name = 'movements'
  end

  class MigrationSegment < ActiveRecord::Base
    self.table_name = 'segments'
  end

  class MigrationExercise < ActiveRecord::Base
    self.table_name = 'exercises'
  end

  def up
    AFFECTED_PAIRS.each do |workout_name, movement_name|
      workout = MigrationWorkout.find_by(name: workout_name)
      raise "Affected workout not found: #{workout_name}" unless workout

      movement = MigrationMovement.find_by(name: movement_name)
      raise "Affected movement not found: #{movement_name}" unless movement

      exercises = MigrationExercise.joins('INNER JOIN segments ON segments.id = exercises.segment_id')
                                    .where(segments: { workout_id: workout.id }, movement_id: movement.id)

      raise "No exercise found for #{workout_name} / #{movement_name}" unless exercises.exists?

      exercises.update_all(load: 0)
    end
  end

  def down
    # Data-only no-op: values set by #up cannot be distinguished from originally nil loads.
  end
end
