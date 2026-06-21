module WorkoutFingerprint
  extend ActiveSupport::Concern

  included do
    before_save :assign_content_key
  end

  # Deterministic identity for the workout's prescribed content: its scoring scheme
  # and ordered parts (top-level exercises and segments, with their prescriptions).
  # Independent of the workout's name, its schedules, and the database ids of its
  # parts, so the same prescription always fingerprints the same regardless of when
  # it is scheduled. Free-text notes are intentionally excluded: they are not a stable
  # prescription field, and bodyweight/percentage loads currently parked in notes are
  # tracked for proper modeling separately (see cf/docs/decisions.md, #1684).
  #
  # Records marked for destruction are excluded so a nested destroy fingerprints the
  # resulting content, not the rows about to be removed. Returns nil for a workout
  # with no parts: an empty workout has no content to deduplicate, and a nil key
  # stays distinct under the unique index.
  def content_fingerprint
    parts = ordered_parts.reject(&:marked_for_destruction?)
    return if parts.empty?

    Digest::SHA256.hexdigest(canonical_content(parts).to_json)
  end

  # Recomputes and persists the key without running validations or callbacks. Used by
  # the content-bearing child records (exercises, segments) whose direct changes are
  # not seen by the workout's own before_save. Resets the cached associations first so
  # the fingerprint reflects the current persisted parts even when a loaded child was
  # changed or destroyed.
  def refresh_content_key!
    exercises.reset
    segments.reset
    update_columns(content_key: content_fingerprint) # rubocop:disable Rails/SkipsModelValidations
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
        exercises: segment.exercises.reject(&:marked_for_destruction?).map { |exercise| canonical_exercise(exercise) }
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
