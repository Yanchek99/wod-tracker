require 'test_helper'

module Devise
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:mathew)
      @user.update!(password: 'password123', password_confirmation: 'password123')
    end

    test 'signing in lands on the schedule page' do
      post user_session_url, params: { user: { email: @user.email, password: 'password123' } }

      assert_redirected_to root_url
      follow_redirect!
      assert_response :success
      assert_instance_of SchedulesController, @controller
    end

    test 'signing in returns to the stored location when one exists' do
      get new_workout_url
      assert_redirected_to new_user_session_url

      post user_session_url, params: { user: { email: @user.email, password: 'password123' } }

      assert_redirected_to new_workout_url
    end

    test 'login page offers sign in with a passkey' do
      get new_user_session_url

      assert_response :success
      assert_select '[data-controller="passkey"][data-passkey-options-url-value=?][data-passkey-url-value=?]',
                    options_passkey_session_path, passkey_session_path
      assert_select 'button[data-action="passkey#authenticate"]', text: 'Sign in with passkey'
    end
  end
end
