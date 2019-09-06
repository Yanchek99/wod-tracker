require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'name is first and last names' do
    brooke = users(:brooke)
    assert_equal "#{brooke.first_name} #{brooke.last_name}", brooke.name
  end
end
