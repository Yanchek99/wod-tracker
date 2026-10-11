require 'test_helper'

module Users
  class PasskeySessionsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    ORIGIN = 'http://www.example.com'.freeze

    setup do
      @user = users(:mathew)
      @user.update!(password: 'password123', password_confirmation: 'password123')
      @authenticator = WebAuthn::FakeAuthenticator.new
      @client = WebAuthn::FakeClient.new(ORIGIN, authenticator: @authenticator)
      register_passkey
      sign_out @user
      delete destroy_user_session_url
    end

    def register_passkey
      sign_in @user
      post options_passkeys_url, as: :json
      credential = @client.create(challenge: response.parsed_body['challenge'], user_verified: true)
      post passkeys_url, params: { credential: credential, label: 'iPhone' }, as: :json
      @passkey = @user.passkeys.last
    end

    def assertion(client: @client, user_verified: true, **get_options)
      post options_passkey_session_url, as: :json
      @options = response.parsed_body
      client.get(challenge: @options['challenge'], user_verified: user_verified, **get_options)
    end

    def sign_in_with(credential)
      post passkey_session_url, params: { credential: credential }, as: :json
    end

    test 'options returns a discoverable-credential request with no allowCredentials' do
      post options_passkey_session_url, as: :json

      assert_response :success
      options = response.parsed_body
      assert_predicate options['challenge'], :present?
      assert_equal 'www.example.com', options['rpId']
      assert_equal 'required', options['userVerification']
      assert_empty Array(options['allowCredentials'])
    end

    test 'a valid assertion signs the user in and returns where to go' do
      sign_in_with(assertion)

      assert_response :success
      assert_equal root_path, response.parsed_body['redirect_to']
      get edit_user_registration_url
      assert_response :success
    end

    test 'a valid assertion updates last_used_at and sets a remember-me cookie' do
      sign_in_with(assertion)

      assert_predicate @passkey.reload.last_used_at, :present?
      assert_match(/remember_user_token=/, Array(response.headers['Set-Cookie']).join("\n"))
    end

    test 'a valid assertion advances the stored sign count' do
      @passkey.update!(sign_count: 5)

      sign_in_with(assertion(sign_count: 6))

      assert_response :success
      assert_equal 6, @passkey.reload.sign_count
    end

    test 'a regressed sign count is rejected' do
      @passkey.update!(sign_count: 10)

      sign_in_with(assertion(sign_count: 3))

      assert_response :unprocessable_entity
      get edit_user_registration_url
      assert_redirected_to new_user_session_url
    end

    test 'a replayed assertion is rejected' do
      credential = assertion
      sign_in_with(credential)
      assert_response :success
      delete destroy_user_session_url

      sign_in_with(credential)

      assert_response :unprocessable_entity
    end

    test 'an assertion from the wrong origin is rejected' do
      evil_client = WebAuthn::FakeClient.new('https://evil.example.com', authenticator: @authenticator)

      sign_in_with(assertion(client: evil_client, rp_id: 'www.example.com'))

      assert_response :unprocessable_entity
    end

    test 'an assertion without user verification is rejected' do
      sign_in_with(assertion(user_verified: false))

      assert_response :unprocessable_entity
    end

    test 'an assertion for an unknown credential is rejected' do
      credential = assertion
      @passkey.destroy!

      sign_in_with(credential)

      assert_response :unprocessable_entity
    end

    test 'a user handle that matches the passkey owner is accepted' do
      handle = Base64.urlsafe_decode64(@user.reload.webauthn_id)

      sign_in_with(assertion(user_handle: handle))

      assert_response :success
    end

    test 'a user handle that does not match the passkey owner is rejected' do
      sign_in_with(assertion(user_handle: 'not-the-owner'))

      assert_response :unprocessable_entity
    end

    test 'sign in without a prior options request is rejected' do
      credential = @client.get(challenge: Base64.urlsafe_encode64('x' * 32, padding: false), user_verified: true)

      sign_in_with(credential)

      assert_response :unprocessable_entity
    end
  end
end
