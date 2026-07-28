require 'test_helper'

class MovementLogsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:mathew)
  end

  test 'personal_records renders every distinct rep-count record for a movement' do
    deadlift = movements(:deadlift)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: deadlift, load: 275, reps: 5)
    log.movement_logs.create!(movement: deadlift, load: 185, reps: 52)

    get personal_records_user_movement_logs_url(users(:mathew))

    assert_response :success
    assert_select 'th', text: 'Deadlift', count: 2
  end

  test 'personal_records orders a movement\'s records by ascending rep count' do
    deadlift = movements(:deadlift)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: deadlift, load: 185, reps: 52)
    log.movement_logs.create!(movement: deadlift, load: 275, reps: 5)

    get personal_records_user_movement_logs_url(users(:mathew))

    assert_response :success
    load_values = response.body.scan(/(\d+) lbs/).flatten.map(&:to_i)
    heavy_load_index = load_values.index(275)
    light_load_index = load_values.index(185)
    assert_operator heavy_load_index, :<, light_load_index
  end
end
