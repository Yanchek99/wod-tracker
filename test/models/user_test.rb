require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'name is first and last names' do
    brooke = users(:brooke)
    assert_equal "#{brooke.first_name} #{brooke.last_name}", brooke.name
  end

  test 'defaults to imperial units and shows loads in pounds' do
    assert_predicate users(:brooke), :unit_system_imperial?
    assert_equal :lb, users(:brooke).load_display_unit
  end

  test 'a metric athlete shows loads in kilograms' do
    brooke = users(:brooke)
    brooke.update!(unit_system: :metric)

    assert_equal :kg, brooke.load_display_unit
  end

  test 'requires sex on user profiles' do
    user = User.new(
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      first_name: 'Test',
      last_name: 'User',
      weight: 180
    )

    assert_not user.valid?
    assert_includes user.errors[:sex], "can't be blank"
  end

  test 'queries user movement history by exact movement and family' do
    mathew = users(:mathew)
    pullup_log = logs(:matt_murph).movement_logs.create!(movement: movements(:pullup), reps: 100)
    strict_pullup = Movement.create!(
      name: 'Strict Pull-up',
      family: :gymnastics,
      equipment: :pull_up_bar,
      skill_level: :intermediate,
      function_roles: { primary: [:vertical_pull] }
    )
    strict_pullup_log = logs(:matt_murph).movement_logs.create!(movement: strict_pullup, reps: 50)
    pushup_log = logs(:matt_murph).movement_logs.create!(movement: movements(:pushup), reps: 200)
    brooke_pullup_log = movement_logs(:brooke_fran_pullup)

    assert_includes mathew.movement_history_for(movements(:pullup)), pullup_log
    assert_not_includes mathew.movement_history_for(movements(:pullup)), brooke_pullup_log

    family_history = mathew.movement_family_history_for(movements(:pullup))
    assert_includes family_history, pullup_log
    assert_includes family_history, strict_pullup_log
    assert_not_includes family_history, pushup_log
    assert_not_includes family_history, brooke_pullup_log
  end
end
