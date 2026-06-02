require 'test_helper'

class LogsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @workout = workouts(:fran)
    sign_in users(:mathew)
  end

  test 'should create log with nested movement metrics' do
    assert_difference('Metric.count', 2) do
      assert_difference(['Log.count', 'MovementLog.count'], 1) do
        post workout_logs_url(@workout), params: { log: {
          metric_attributes: { measurement: :time, value: '5:30' },
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

    assert_redirected_to log_url(Log.last)
    assert_equal movements(:pullup), Log.last.movement_logs.first.movement
    assert_equal 45, Log.last.movement_logs.first.metrics.find_by!(measurement: :rep).value
  end
end
