require 'test_helper'

class ScheduleWeekTest < ActiveSupport::TestCase
  setup do
    @user = users(:mathew)
    @period = Time.zone.local(2026, 8, 10)...Time.zone.local(2026, 8, 17)
    @fran = workouts(:fran)
    @murph = workouts(:murph)
  end

  test 'counts scheduled workouts and those logged during the week' do
    log_for(@fran, 300, Time.zone.local(2026, 8, 11))
    log_for(@murph, 3600, Time.zone.local(2026, 7, 1))

    week = build_week([@fran, @murph])

    assert_equal 2, week.scheduled_count
    assert_equal 1, week.logged_count
  end

  test 'a workout scheduled twice in the week counts once' do
    week = ScheduleWeek.new(workout_ids: [@fran.id, @fran.id], histories: {}, period: @period)

    assert_equal 1, week.scheduled_count
  end

  test 'new PRs are workouts whose best result was logged during the week' do
    log_for(@fran, 400, Time.zone.local(2026, 7, 1))
    log_for(@fran, 300, Time.zone.local(2026, 8, 12))
    log_for(@murph, 3000, Time.zone.local(2026, 7, 2))
    log_for(@murph, 3600, Time.zone.local(2026, 8, 12))

    assert_equal 1, build_week([@fran, @murph]).new_pr_count
  end

  test 'a workout logged once has no PR to count' do
    log_for(@fran, 300, Time.zone.local(2026, 8, 12))

    assert_equal 0, build_week([@fran]).new_pr_count
  end

  test 'nothing logged gives zeros' do
    week = build_week([@fran])

    assert_equal 0, week.logged_count
    assert_equal 0, week.new_pr_count
  end

  private

  def build_week(workouts)
    ids = workouts.map(&:id)
    histories = WorkoutHistory.for(@user.logs.where(workout_id: ids).includes(:workout))
    ScheduleWeek.new(workout_ids: ids, histories: histories, period: @period)
  end

  def log_for(workout, score, created_at)
    Log.create!(user: @user, workout: workout, score_type: 'time', score_value: score, created_at: created_at)
  end
end
