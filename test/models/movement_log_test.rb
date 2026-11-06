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

  test 'compacts blank entries out of set_breakdown instead of crashing' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.assign_attributes(reps: 21, set_breakdown: [21, nil])

    assert_predicate movement_log, :valid?
    assert_equal [21], movement_log.set_breakdown
  end

  test 'is invalid when set_breakdown contains a non-positive value' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.assign_attributes(reps: 15, set_breakdown: [15, 0])

    assert_not movement_log.valid?
    assert_includes movement_log.errors[:set_breakdown], 'must contain only positive numbers'
  end

  test 'set_breakdown_text parses a comma-separated string into set_breakdown' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.set_breakdown_text = '8,7,6'

    assert_equal [8, 7, 6], movement_log.set_breakdown
  end

  test 'set_breakdown_text tolerates whitespace and double commas' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.set_breakdown_text = ' 8 , , 7,6 '

    assert_equal [8, 7, 6], movement_log.set_breakdown
  end

  test 'set_breakdown_text treats dashes and commas as equivalent separators' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.set_breakdown_text = '10,10,10,10,8-2,8-2'

    assert_equal [10, 10, 10, 10, 8, 2, 8, 2], movement_log.set_breakdown
  end

  test 'set_breakdown_text dash and comma versions of the same input produce identical results' do
    dash_version = movement_logs(:brooke_fran_thruster)
    dash_version.set_breakdown_text = '10,10,10,10,8-2,8-2'

    comma_version = movement_logs(:brooke_fran_pullup)
    comma_version.set_breakdown_text = '10,10,10,10,8,2,8,2'

    assert_equal dash_version.set_breakdown, comma_version.set_breakdown
  end

  test 'set_breakdown_text rejects non-numeric characters' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.set_breakdown_text = '8,seven,6'

    assert_not movement_log.valid?
    assert_includes movement_log.errors[:set_breakdown_text], 'can only contain numbers, commas, dashes, and spaces'
  end

  test 'set_breakdown_text still rejects letters even with dash separators allowed' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.set_breakdown_text = '10-ten'

    assert_not movement_log.valid?
    assert_includes movement_log.errors[:set_breakdown_text], 'can only contain numbers, commas, dashes, and spaces'
  end

  test 'set_breakdown_text accepts digits, commas, and spaces only' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.reps = 21
    movement_log.set_breakdown_text = '8, 7, 6'

    assert_predicate movement_log, :valid?
  end

  test 'set_breakdown_text blank clears set_breakdown' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.set_breakdown = [8, 7, 6]
    movement_log.set_breakdown_text = ''

    assert_empty movement_log.set_breakdown
  end

  test 'set_breakdown_text reader joins set_breakdown back into a comma-separated string' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.set_breakdown = [8, 7, 6]

    assert_equal '8, 7, 6', movement_log.set_breakdown_text
  end

  test 'set_breakdown_text reader is nil when set_breakdown is blank' do
    movement_log = movement_logs(:brooke_fran_thruster)

    assert_nil movement_log.set_breakdown_text
  end
end
