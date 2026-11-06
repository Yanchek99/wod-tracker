# Groups a user's movement logs into "the same test attempted more than once" and keeps the best
# attempt per group. Which dimension counts as the group ("what was fixed") versus the ranked
# outcome ("what you were trying to beat") depends on which columns the log recorded -- see the
# rule table in https://github.com/Yanchek99/wod-tracker/issues/1829.
class MovementRecordSet
  Candidate = Struct.new(:movement_log, :group_key, :rank_value)

  def initialize(movement_logs)
    @movement_logs = movement_logs
  end

  def records
    @movement_logs
      .filter_map { |movement_log| candidate_for(movement_log) }
      .group_by { |candidate| [candidate.movement_log.movement_id, candidate.group_key] }
      .values
      .map { |candidates| candidates.max_by(&:rank_value).movement_log }
  end

  private

  def candidate_for(movement_log)
    return load_for_time_candidate(movement_log) if load_for_time?(movement_log)
    return load_candidate(movement_log) if movement_log.load.present?
    return distance_or_duration_candidate(movement_log) if movement_log.distance.present? || movement_log.duration_seconds.present?

    bare_metric_candidate(movement_log)
  end

  def load_candidate(movement_log)
    group_key = [:load, movement_log.reps, movement_log.distance, movement_log.duration_seconds, movement_log.calories]
    Candidate.new(movement_log, group_key, movement_log.load)
  end

  # A fixed load/reps/distance test scored by elapsed time (e.g. "1000 Box Step-ups @ 45lb/20in
  # for time") -- distinct from a find-a-max-with-time-cap test (`load_candidate`), where duration
  # is a fixed cap and load is what you're trying to beat. Distinguished by a fixed distance also
  # being present alongside load and duration.
  def load_for_time?(movement_log)
    movement_log.load.present? && movement_log.distance.present? && movement_log.duration_seconds.present?
  end

  def load_for_time_candidate(movement_log)
    group_key = [:load_for_time, movement_log.load, movement_log.reps, movement_log.distance, movement_log.calories]
    Candidate.new(movement_log, group_key, -movement_log.duration_seconds)
  end

  # Distance without load is either a for-time test (paired with duration) or a bare, unranked
  # distance number -- the latter isn't a meaningful record on its own, so it's skipped.
  def distance_or_duration_candidate(movement_log)
    return distance_duration_candidate(movement_log) if movement_log.distance.present? && movement_log.duration_seconds.present?
    return if movement_log.distance.present?

    duration_secondary_candidate(movement_log)
  end

  def distance_duration_candidate(movement_log)
    Candidate.new(movement_log, [:distance, movement_log.distance], -movement_log.duration_seconds)
  end

  # A fixed-duration test (e.g. "max double-unders in 60 seconds") is ranked by whichever
  # secondary metric it recorded.
  def duration_secondary_candidate(movement_log)
    return duration_reps_candidate(movement_log) if movement_log.reps.present?

    duration_calories_candidate(movement_log) if movement_log.calories.present?
  end

  def duration_reps_candidate(movement_log)
    Candidate.new(movement_log, [:duration_reps, movement_log.duration_seconds], movement_log.reps)
  end

  def duration_calories_candidate(movement_log)
    Candidate.new(movement_log, [:duration_calories, movement_log.duration_seconds], movement_log.calories)
  end

  def bare_metric_candidate(movement_log)
    return Candidate.new(movement_log, :calories, movement_log.calories) if movement_log.calories.present?

    Candidate.new(movement_log, :reps, movement_log.reps) if movement_log.reps.present?
  end
end
