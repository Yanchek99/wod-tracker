require 'test_helper'

module Devise
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:mathew)
      @user.update!(password: 'password123', password_confirmation: 'password123')
    end

    test 'signing in lands on the schedule page for the current day' do
      post user_session_url, params: { user: { email: @user.email, password: 'password123' } }

      assert_redirected_to schedules_url(date: Date.current)
    end

    test 'signing in returns to the stored location when one exists' do
      get new_workout_url
      assert_redirected_to new_user_session_url

      post user_session_url, params: { user: { email: @user.email, password: 'password123' } }

      assert_redirected_to new_workout_url
    end
  end
end
