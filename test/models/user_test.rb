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
end
