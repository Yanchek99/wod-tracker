require 'test_helper'

class LogsRoutingTest < ActionDispatch::IntegrationTest
  test 'does not route nested logs index' do
    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path('/workouts/1/logs', method: :get)
    end
  end

  test 'routes nested log creation' do
    assert_routing({ method: :post, path: '/workouts/1/logs' },
                   controller: 'logs', action: 'create', workout_id: '1')
  end
end
