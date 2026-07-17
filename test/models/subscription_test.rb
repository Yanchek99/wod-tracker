require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  test 'requires a role' do
    subscription = Subscription.new(program: programs(:crossfit), user: users(:brooke), role: nil)

    assert_not subscription.valid?
    assert_includes subscription.errors[:role], "can't be blank"
  end
end
