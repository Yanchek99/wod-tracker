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

  test 'is valid when set_breakdown sums to reps' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.assign_attributes(reps: 15, set_breakdown: [8, 7])

    assert_predicate movement_log, :valid?
  end

  test 'is invalid when set_breakdown does not sum to reps' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.assign_attributes(reps: 15, set_breakdown: [8, 6])

    assert_not movement_log.valid?
    assert_includes movement_log.errors[:set_breakdown], 'must sum to reps'
  end

  test 'is valid with a blank set_breakdown regardless of reps' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.assign_attributes(reps: 15, set_breakdown: [])

    assert_predicate movement_log, :valid?
  end
end
