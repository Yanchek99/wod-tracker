# A user's logged results for one workout, as shown beside it on the Schedule page.
class WorkoutHistory
  # Builds histories keyed by workout_id from one user's logs.
  def self.for(logs)
    logs.group_by(&:workout_id).transform_values { |workout_logs| new(workout_logs) }
  end

  def initialize(logs)
    @logs = logs
  end

  def count
    @logs.size
  end

  def last_log
    @last_log ||= @logs.max_by(&:created_at)
  end

  # A best only exists for a repeated, non-lifting workout, matching User#workout_records.
  def best_log
    return if count < 2 || @logs.first.workout.score_weight?

    best = @logs.max_by(&:rank_value)
    @best_log ||= best unless best.score_value.nil?
  end

  def logged_during?(period)
    @logs.any? { |log| period.cover?(log.created_at) }
  end

  def best_during?(period)
    best = best_log
    best.present? && period.cover?(best.created_at)
  end
end
