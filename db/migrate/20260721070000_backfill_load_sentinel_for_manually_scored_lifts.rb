class BackfillLoadSentinelForManuallyScoredLifts < ActiveRecord::Migration[8.1]
  MEASUREMENTS_BY_VALUE = {
    0 => 'calorie', 1 => 'rep', 2 => 'round', 3 => 'seconds',
    4 => 'inch', 5 => 'foot', 6 => 'meter',
    7 => 'lb', 8 => 'kg',
    9 => 'time', 10 => 'weight', 11 => 'height', 12 => 'distance'
  }.freeze

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
  end

  class MigrationExercise < ActiveRecord::Base
    self.table_name = 'exercises'
  end

  def up
    affected_workout_ids = AFFECTED_PAIRS.map { |workout_name, movement_name| backfill_pair(workout_name, movement_name) }

    affected_workout_ids.uniq.each { |workout_id| refresh_content_key(workout_id) }
  end

  def down
    # Data-only no-op: values set by #up cannot be distinguished from originally nil loads.
  end

  private

  def backfill_pair(workout_name, movement_name)
    workout = MigrationWorkout.find_by(name: workout_name)
    raise "Affected workout not found: #{workout_name}" unless workout

    movement = MigrationMovement.find_by(name: movement_name)
    raise "Affected movement not found: #{movement_name}" unless movement

    exercises = MigrationExercise
                .joins('INNER JOIN segments ON segments.id = exercises.segment_id')
                .where(segments: { workout_id: workout.id }, movement_id: movement.id)

    raise "No exercise found for #{workout_name} / #{movement_name}" unless exercises.exists?

    exercises.find_each { |exercise| exercise.update!(load: 0) }
    workout.id
  end

  def refresh_content_key(workout_id)
    workout = MigrationWorkout.find(workout_id)
    key = content_fingerprint(workout)
    key = nil if key && MigrationWorkout.where.not(id: workout.id).exists?(content_key: key)

    workout.update!(content_key: key)
  end

  def content_fingerprint(workout)
    segments = MigrationSegment.where(workout_id: workout.id).order(:position, :id)
    return if segments.empty?

    Digest::SHA256.hexdigest(canonical_content(workout, segments).to_json)
  end

  def canonical_content(workout, segments)
    {
      score_type: MEASUREMENTS_BY_VALUE.fetch(workout.score_type),
      time_cap_seconds: workout.time_cap_seconds,
      ladder_step: workout.ladder_step,
      team_size: workout.team_size,
      parts: segments.map { |segment| canonical_segment(segment) }
    }
  end

  def canonical_segment(segment)
    {
      segment: {
        rounds: segment.rounds,
        time_seconds: segment.time_seconds,
        interval_scheme: segment.interval_scheme,
        rest_seconds: segment.rest_seconds,
        exercises: MigrationExercise.where(segment_id: segment.id).order(:position, :id).map { |exercise| canonical_exercise(exercise) }
      }
    }
  end

  def canonical_exercise(exercise)
    {
      movement_id: exercise.movement_id,
      reps: exercise.reps,
      ladder_step_every: exercise.ladder_step_every,
      ladder_exempt: exercise.ladder_exempt,
      duration_seconds: exercise.duration_seconds,
      load: exercise.load,
      female_load: exercise.female_load,
      male_load: exercise.male_load,
      distance: exercise.distance,
      female_distance: exercise.female_distance,
      male_distance: exercise.male_distance,
      distance_unit: exercise.distance_unit,
      distance_units_per_rep: exercise.distance_units_per_rep,
      calories: exercise.calories,
      female_calories: exercise.female_calories,
      male_calories: exercise.male_calories
    }
  end
end
