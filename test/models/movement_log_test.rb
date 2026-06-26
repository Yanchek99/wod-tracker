require 'test_helper'

class MovementLogTest < ActiveSupport::TestCase
  test 'records the implement count on the load metric' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.update!(load: 50, load_unit: :lb, implement_count: 2)

    load_metric = movement_log.prescription_metrics.find { |metric| metric.measurement == 'lb' }

    assert_equal 2, load_metric.implement_count
  end

  test 'clears the implement count when no load is recorded' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.assign_attributes(load: nil, load_unit: :lb, implement_count: 2)
    movement_log.validate

    assert_nil movement_log.implement_count
  end

  test 'queries history by exact movement' do
    logs(:matt_murph).movement_logs.create!(movement: movements(:pullup), reps: 100)

    results = MovementLog.for_movement(movements(:pullup))

    assert_includes results, movement_logs(:brooke_fran_pullup)
    assert_includes results, logs(:matt_murph).movement_logs.last
    assert_not_includes results, movement_logs(:brooke_fran_thruster)
  end

  test 'queries history by movement family' do
    pushup_log = logs(:matt_murph).movement_logs.create!(movement: movements(:pushup), reps: 200)

    results = MovementLog.for_movement_family(movements(:pullup))

    assert_includes results, movement_logs(:brooke_fran_pullup)
    assert_includes results, pushup_log
    assert_not_includes results, movement_logs(:brooke_fran_thruster)
  end
end
