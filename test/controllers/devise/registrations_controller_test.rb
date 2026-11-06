require 'test_helper'

module Devise
  class RegistrationsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = users(:mathew)
      @user.update!(password: 'password123', password_confirmation: 'password123')
      sign_in @user
    end

    test 'profile-only updates do not require the current password' do
      put user_registration_url, params: { user: { first_name: 'Matthew' } }

      assert_redirected_to edit_user_registration_url
      assert_equal 'Your account has been updated successfully.', flash[:notice]
      assert_equal 'Matthew', @user.reload.first_name
    end

    test 'email updates require the current password' do
      put user_registration_url, params: { user: { email: 'new@example.com' } }

      assert_response :unprocessable_entity
      assert_equal 'mathew.fraser@wod-tracker.com', @user.reload.email
    end

    test 'password updates require the current password' do
      put user_registration_url, params: {
        user: { password: 'new-password123', password_confirmation: 'new-password123' }
      }

      assert_response :unprocessable_entity
      assert @user.reload.valid_password?('password123')
    end

    test 'email and password updates accept the correct current password' do
      put user_registration_url, params: {
        user: {
          email: 'new@example.com',
          password: 'new-password123',
          password_confirmation: 'new-password123',
          current_password: 'password123'
        }
      }

      assert_redirected_to edit_user_registration_url
      assert_equal 'Your account has been updated successfully.', flash[:notice]
      assert_equal 'new@example.com', @user.reload.email
      assert @user.valid_password?('new-password123')
    end

    test 'edit form does not universally require the current password' do
      get edit_user_registration_url

      assert_response :success
      assert_select 'h3', text: 'Change password'
      assert_select 'input[name="user[current_password]"]:not([required])'
    end

    test 'edit page lists passkeys with a remove link and an add button' do
      passkey = @user.passkeys.create!(external_id: 'cred-1', public_key: 'key', label: 'My iPhone')

      get edit_user_registration_url

      assert_select '.list-group-item .fw-semibold', text: 'My iPhone'
      assert_select '.list-group-item small', text: 'Never used'
      assert_select 'a[href=?][data-turbo-method="delete"]', passkey_path(passkey), text: 'Remove'
      assert_select 'button[data-action="passkey#register"]', text: 'Add a passkey'
    end

    test 'edit page without passkeys shows no list' do
      get edit_user_registration_url

      assert_select '.list-group-item', count: 0
      assert_select 'button[data-action="passkey#register"]'
    end
  end
end
