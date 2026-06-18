module WorkoutFingerprint
  extend ActiveSupport::Concern

  included do
    before_save :assign_content_key
  end

  # Deterministic identity for the workout's prescribed content: its scoring scheme
  # and ordered parts (top-level exercises and segments). Independent of the
  # workout's name, its schedules, and the database ids of its parts, so the same
  # prescription always fingerprints the same regardless of when it is scheduled.
  #
  # Returns nil for a workout with no parts: an empty workout has no content to
  # deduplicate, and a nil key stays distinct under the unique index.
  def content_fingerprint
    parts = ordered_parts
    return if parts.empty?

    Digest::SHA256.hexdigest(canonical_content(parts).to_json)
  end

  private

  def canonical_content(parts)
    {
      score_type:,
      rounds:,
      time:,
      interval:,
      time_cap_seconds:,
      parts: parts.map { |part| canonical_part(part) }
    }
  end

  def canonical_part(part)
    part.is_a?(Segment) ? canonical_segment(part) : { exercise: canonical_exercise(part) }
  end

  def canonical_segment(segment)
    {
      segment: {
        rounds: segment.rounds,
        time_seconds: segment.time_seconds,
        interval_scheme: segment.interval_scheme,
        rest_seconds: segment.rest_seconds,
        exercises: segment.exercises.map { |exercise| canonical_exercise(exercise) }
      }
    }
  end

  def canonical_exercise(exercise)
    {
      movement_id: exercise.movement_id,
      reps: exercise.reps,
      duration_seconds: exercise.duration_seconds,
      load: exercise.load,
      female_load: exercise.female_load,
      male_load: exercise.male_load,
      load_unit: exercise.load_unit,
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

  def assign_content_key
    self.content_key = content_fingerprint
  end
end
