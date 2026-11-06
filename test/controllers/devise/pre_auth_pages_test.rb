require 'test_helper'

module Devise
  class PreAuthPagesTest < ActionDispatch::IntegrationTest
    test 'sign up page uses the auth layout with password toggles on both password fields' do
      get new_user_registration_url

      assert_response :success
      assert_select 'h1.auth-title', 'Create your account'
      assert_select '[data-controller="password-toggle"]', count: 2
      assert_select 'input[type=submit][value="Create account"]'
    end

    test 'sign up errors are shown against the fields, including the sex select' do
      post user_registration_url, params: { user: { email: '' } }

      assert_response :unprocessable_entity
      assert_select 'select#user_sex.is-invalid'
      assert_select '.invalid-feedback', text: /Sex can't be blank/
    end

    test 'forgot password page explains what will happen' do
      get new_user_password_url

      assert_response :success
      assert_select 'h1.auth-title', 'Reset your password'
      assert_select 'input[type=submit][value="Send reset link"]'
    end

    test 'reset password page has toggles on both password fields' do
      get edit_user_password_url(reset_password_token: 'token')

      assert_response :success
      assert_select 'h1.auth-title', 'Choose a new password'
      assert_select '[data-controller="password-toggle"]', count: 2
    end
  end
end
