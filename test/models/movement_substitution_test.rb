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

  test 'rejects inverse movement pairs with the same direction' do
    substitution = MovementSubstitution.new(
      movement: movements(:back_squat),
      substitute_movement: movements(:front_squat),
      direction: :easier
    )

    assert_not substitution.valid?
    assert_includes substitution.errors[:substitute_movement], 'already has an inverse substitution'
  end

  test 'rejects inverse movement pairs with complementary directions' do
    substitution = MovementSubstitution.new(
      movement: movements(:back_squat),
      substitute_movement: movements(:front_squat),
      direction: :harder
    )

    assert_not substitution.valid?
    assert_includes substitution.errors[:substitute_movement], 'already has an inverse substitution'
  end

  test 'database rejects inverse movement pairs' do
    timestamp = MovementSubstitution.connection.quote(Time.current)

    assert_raises ActiveRecord::RecordNotUnique do
      MovementSubstitution.connection.execute(<<~SQL.squish)
        INSERT INTO movement_substitutions
          (movement_id, substitute_movement_id, direction, created_at, updated_at)
        VALUES
          (#{movements(:back_squat).id}, #{movements(:front_squat).id},
           #{MovementSubstitution.directions.fetch(:harder)}, #{timestamp}, #{timestamp})
      SQL
    end
  end

  test 'rejects inverse lateral movement pairs as redundant' do
    substitution = MovementSubstitution.new(
      movement: movements(:row),
      substitute_movement: movements(:run),
      direction: :lateral
    )

    assert_not substitution.valid?
    assert_includes substitution.errors[:substitute_movement], 'already has an inverse substitution'
  end
end
