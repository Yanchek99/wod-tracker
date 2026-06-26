require 'test_helper'

class MovementSubstitutionTest < ActiveSupport::TestCase
  test 'stores directed substitutions' do
    substitution = movement_substitutions(:pullup_pushup)

    assert substitution.direction_easier?
    assert_equal movements(:pullup), substitution.movement
    assert_equal movements(:pushup), substitution.substitute_movement
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
      movement: movements(:pullup),
      substitute_movement: movements(:pushup),
      direction: :harder
    )

    assert_not substitution.valid?
    assert_includes substitution.errors[:substitute_movement_id], 'has already been taken'
  end
end
