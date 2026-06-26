require 'test_helper'

class MovementTest < ActiveSupport::TestCase
  test 'supports implement count for dumbbell and kettlebell movements' do
    assert_predicate Movement.new(name: 'Dumbbell Thruster'), :supports_implement_count?
    assert_predicate Movement.new(name: 'kettlebell swing'), :supports_implement_count?
  end

  test 'supports implement count from equipment taxonomy' do
    assert_predicate Movement.new(name: 'Thruster', equipment: :dumbbell), :supports_implement_count?
    assert_predicate Movement.new(name: 'Swing', equipment: :kettlebell), :supports_implement_count?
  end

  test 'does not support implement count for other movements' do
    assert_not Movement.new(name: 'Back Squat').supports_implement_count?
    assert_not Movement.new(name: 'Pull Up').supports_implement_count?
  end

  test 'scopes movements that support implement count' do
    dumbbell = Movement.create!(name: 'Dumbbell Snatch')
    kettlebell = Movement.create!(name: 'Kettlebell Clean')

    supported = Movement.supporting_implement_count

    assert_includes supported, dumbbell
    assert_includes supported, kettlebell
    assert_not_includes supported, movements(:back_squat)
  end

  test 'stores structured movement taxonomy' do
    thruster = movements(:thruster)

    assert thruster.family_weightlifting?
    assert thruster.pattern_mixed?
    assert thruster.equipment_barbell?
    assert thruster.skill_level_intermediate?
  end

  test 'finds movements in the same family' do
    pullup = movements(:pullup)

    assert_includes pullup.family_movements, movements(:pushup)
    assert_not_includes pullup.family_movements, movements(:run)
  end
end
