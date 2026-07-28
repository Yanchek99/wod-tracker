# Groups a user's movement logs into "the same test attempted more than once" and keeps the best
# attempt per group. Which dimension counts as the group ("what was fixed") versus the ranked
# outcome ("what you were trying to beat") depends on which columns the log recorded -- see the
# rule table in docs/superpowers/plans/2026-07-28-pr-view-redesign.md.
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
    if movement_log.load.present?
      load_candidate(movement_log)
    elsif movement_log.distance.present? && movement_log.duration_seconds.present?
      distance_duration_candidate(movement_log)
    elsif movement_log.distance.present?
      nil
    elsif movement_log.duration_seconds.present? && movement_log.reps.present?
      duration_reps_candidate(movement_log)
    elsif movement_log.duration_seconds.present? && movement_log.calories.present?
      duration_calories_candidate(movement_log)
    elsif movement_log.calories.present?
      Candidate.new(movement_log, :calories, movement_log.calories)
    elsif movement_log.reps.present?
      Candidate.new(movement_log, :reps, movement_log.reps)
    end
  end

  def load_candidate(movement_log)
    group_key = [:load, movement_log.reps, movement_log.distance, movement_log.duration_seconds, movement_log.calories]
    Candidate.new(movement_log, group_key, movement_log.load)
  end

  def distance_duration_candidate(movement_log)
    Candidate.new(movement_log, [:distance, movement_log.distance], -movement_log.duration_seconds)
  end

  def duration_reps_candidate(movement_log)
    Candidate.new(movement_log, [:duration_reps, movement_log.duration_seconds], movement_log.reps)
  end

  def duration_calories_candidate(movement_log)
    Candidate.new(movement_log, [:duration_calories, movement_log.duration_seconds], movement_log.calories)
  end
end
