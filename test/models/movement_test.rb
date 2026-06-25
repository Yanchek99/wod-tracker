require 'test_helper'

class MovementTest < ActiveSupport::TestCase
  test 'supports implement count for dumbbell and kettlebell movements' do
    assert_predicate Movement.new(name: 'Dumbbell Thruster'), :supports_implement_count?
    assert_predicate Movement.new(name: 'kettlebell swing'), :supports_implement_count?
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
end
