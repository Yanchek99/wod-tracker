# The "This week" panel on the Schedule page: how many of the week's scheduled workouts the user logged
# and how many of them set a new best during the week.
class ScheduleWeek
  # workout_ids: workouts scheduled in the week; histories: WorkoutHistory by workout_id; period: Time range.
  def initialize(workout_ids:, histories:, period:)
    @workout_ids = workout_ids.uniq
    @histories = histories
    @period = period
  end

  def scheduled_count
    @workout_ids.size
  end

  def logged_count
    scheduled_histories.count { |history| history.logged_during?(@period) }
  end

  def new_pr_count
    scheduled_histories.count { |history| history.best_during?(@period) }
  end

  private

  def scheduled_histories
    @histories.values_at(*@workout_ids).compact
  end
end
