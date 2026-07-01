require 'test_helper'

class MovementSubstitutionTest < ActiveSupport::TestCase
  test 'stores directed substitutions' do
    substitution = movement_substitutions(:backsqt_frontsqt)

    assert substitution.direction_easier?
    assert_equal movements(:front_squat), substitution.movement
    assert_equal movements(:back_squat), substitution.substitute_movement
  end

  test 'requires substitute to be different from movement' do
    substitution = MovementSubstitution.new(
      movement: movements(:pullup),
      substitute_movement: movements(:pullup),
      direction: :easier
    )

    assert_not substitution.valid?
    assert_includes substitution.errors[:substitute_movement], 'must be different from movement'
  end

  test 'allows only one direction per ordered movement pair' do
    substitution = MovementSubstitution.new(
      movement: movements(:front_squat),
      substitute_movement: movements(:back_squat),
      direction: :harder
    )

    assert_not substitution.valid?
    assert_includes substitution.errors[:substitute_movement_id], 'has already been taken'
  end

  test 'rejects contradictory inverse directions' do
    substitution = MovementSubstitution.new(
      movement: movements(:back_squat),
      substitute_movement: movements(:front_squat),
      direction: :easier
    )

    assert_not substitution.valid?
    assert_includes substitution.errors[:direction], 'contradicts inverse substitution'
  end
end
