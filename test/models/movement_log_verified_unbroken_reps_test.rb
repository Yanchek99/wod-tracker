require 'test_helper'

class MovementLogVerifiedUnbrokenRepsTest < ActiveSupport::TestCase
  test 'verified_unbroken_reps is nil when reps is blank' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.reps = nil

    assert_nil movement_log.verified_unbroken_reps
  end

  test 'verified_unbroken_reps trusts reps <= 1 without a set_breakdown' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.reps = 1

    assert_equal 1, movement_log.verified_unbroken_reps
  end

  test 'verified_unbroken_reps is nil for reps > 1 with no captured set_breakdown' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.reps = 21

    assert_nil movement_log.verified_unbroken_reps
  end

  test 'verified_unbroken_reps is the largest captured set for reps > 1' do
    movement_log = movement_logs(:brooke_fran_thruster)
    movement_log.assign_attributes(reps: 45, set_breakdown: [21, 15, 9])

    assert_equal 21, movement_log.verified_unbroken_reps
  end
end
