require 'test_helper'

class WorkoutHistoryTest < ActiveSupport::TestCase
  setup do
    @user = users(:mathew)
    @workout = workouts(:fran)
  end

  test 'tracks last log, best log and count for repeated time workouts' do
    slow = log_for(@workout, 400, 3.days.ago)
    fast = log_for(@workout, 300, 2.days.ago)
    middle = log_for(@workout, 350, 1.day.ago)

    history = WorkoutHistory.for([slow, fast, middle])[@workout.id]

    assert_equal middle, history.last_log
    assert_equal fast, history.best_log
    assert_equal 3, history.count
  end

  test 'best log is higher score for non-time workouts' do
    amrap = workouts(:amrap_couplet)
    low = log_for(amrap, 100, 2.days.ago, score_type: 'rep')
    high = log_for(amrap, 202, 1.day.ago, score_type: 'rep')

    assert_equal high, WorkoutHistory.for([low, high])[amrap.id].best_log
  end

  test 'a single log has no best log' do
    only = log_for(@workout, 330, 1.day.ago)

    history = WorkoutHistory.for([only])[@workout.id]

    assert_nil history.best_log
    assert_equal only, history.last_log
    assert_equal 1, history.count
  end

  test 'lifting workouts have no best log' do
    @workout.update!(score_type: 'weight')
    first = log_for(@workout, 100, 2.days.ago, score_type: 'weight')
    second = log_for(@workout, 110, 1.day.ago, score_type: 'weight')

    assert_nil WorkoutHistory.for([first, second])[@workout.id].best_log
  end

  test 'a log without a score never wins best' do
    unscored = log_for(@workout, nil, 2.days.ago)
    scored = log_for(@workout, 300, 1.day.ago)

    assert_equal scored, WorkoutHistory.for([unscored, scored])[@workout.id].best_log
  end

  test 'workouts without logs are absent' do
    assert_empty WorkoutHistory.for([])
  end

  test 'Log#rank_value is negated for time scores and infinitely low without a score' do
    assert_equal(-300, log_for(@workout, 300, 1.day.ago).rank_value)
    assert_equal(-Float::INFINITY, log_for(@workout, nil, 1.day.ago).rank_value)
    assert_equal 202, log_for(workouts(:amrap_couplet), 202, 1.day.ago, score_type: 'rep').rank_value
  end

  private

  def log_for(workout, score, created_at, score_type: 'time')
    Log.create!(user: @user, workout: workout, score_type: score_type, score_value: score, created_at: created_at)
  end
end
