require 'test_helper'

class LogsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @workout = workouts(:fran)
    sign_in users(:mathew)
  end

  test 'should create log with nested movement metrics' do
    assert_difference('Metric.where(measurable_type: "Log").count', 0) do
      assert_difference('Metric.count', 1) do
        assert_difference(['Log.count', 'MovementLog.count'], 1) do
          post workout_logs_url(@workout), params: { log: {
            score_type: :time,
            score_value: '5:30',
            movement_logs_attributes: {
              '0' => {
                movement_id: movements(:pullup).id,
                metrics_attributes: {
                  '0' => { measurement: :rep, value: 45 }
                }
              }
            }
          } }
        end
      end
    end

    assert_equal ['time', 330, nil], [Log.last.score_type, Log.last.score_value, Log.last.metric]
    assert_equal [movements(:pullup), 45],
                 [Log.last.movement_logs.first.movement,
                  Log.last.movement_logs.first.metrics.find_by!(measurement: :rep).value]
  end

  test 'should not show another user log' do
    get log_url(logs(:brooke_fran))

    assert_response :not_found
  end

  test 'should not edit another user log' do
    get edit_workout_log_url(logs(:brooke_fran).workout, logs(:brooke_fran))

    assert_response :not_found
  end

  test 'should not update another user log' do
    patch workout_log_url(logs(:brooke_fran).workout, logs(:brooke_fran)), params: {
      log: { score_type: :time, score_value: '4:59' }
    }

    assert_response :not_found
  end

  test 'should not destroy another user log' do
    assert_no_difference('Log.count') do
      delete log_url(logs(:brooke_fran))
    end

    assert_response :not_found
  end

  test 'creates amrap log from rounds plus reps score' do
    assert_difference('Log.count') do
      post workout_logs_url(workouts(:amrap_couplet)), params: { log: {
        score_type: :rep,
        score_value: '20+2'
      } }
    end

    assert_redirected_to log_url(Log.last)
    assert_equal 502, Log.last.score_value
    assert_equal 25, Log.last.reps_per_round
  end

  test 'new log for fixed-rep round-scored amrap uses rep score input' do
    workout = workouts(:amrap_couplet)
    workout.update!(score_type: :round)

    get new_workout_log_url(workout)

    assert_response :success
    assert_select 'input[name="log[score_type]"][value="rep"]'
  end

  test 'creates fixed-rep amrap log from stale round score submission' do
    workout = workouts(:amrap_couplet)
    workout.update!(score_type: :round)

    assert_difference('Log.count') do
      post workout_logs_url(workout), params: { log: {
        score_type: :round,
        score_value: '20+2'
      } }
    end

    assert_redirected_to log_url(Log.last)
    assert_equal 'rep', Log.last.score_type
    assert_equal 502, Log.last.score_value
    assert_equal 25, Log.last.reps_per_round
  end

  test 'creates amrap log from raw total reps' do
    assert_difference('Log.count') do
      post workout_logs_url(workouts(:amrap_couplet)), params: { log: {
        score_type: :rep,
        score_value: '202'
      } }
    end

    assert_equal 202, Log.last.score_value
    assert_equal 25, Log.last.reps_per_round
  end

  test 'does not create amrap log from invalid rounds plus reps score' do
    assert_no_difference('Log.count') do
      post workout_logs_url(workouts(:amrap_couplet)), params: { log: {
        score_type: :rep,
        score_value: '2.5'
      } }
    end

    assert_response :unprocessable_content
  end
end
