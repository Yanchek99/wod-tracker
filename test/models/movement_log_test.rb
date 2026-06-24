require 'test_helper'

class MovementLogTest < ActiveSupport::TestCase
  test 'records the implement count on the load metric' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.update!(load: 50, load_unit: :lb, implement_count: 2)

    load_metric = movement_log.prescription_metrics.find { |metric| metric.measurement == 'lb' }

    assert_equal 2, load_metric.implement_count
  end

  test 'resets the implement count to one when no load is recorded' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.assign_attributes(load: nil, load_unit: :lb, implement_count: 2)
    movement_log.validate

    assert_equal 1, movement_log.implement_count
  end

  test 'defaults a new movement log to a single implement' do
    assert_equal 1, MovementLog.new.implement_count
  end
end
