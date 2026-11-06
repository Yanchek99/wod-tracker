require 'test_helper'

class PasskeysControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  ORIGIN = 'http://www.example.com'.freeze

  setup do
    @user = users(:mathew)
    @authenticator = WebAuthn::FakeAuthenticator.new
    @client = WebAuthn::FakeClient.new(ORIGIN, authenticator: @authenticator)
    sign_in @user
  end

  def registration_options
    post options_passkeys_url, as: :json
    response.parsed_body
  end

  def register(client: @client, label: 'iPhone', **create_options)
    options = registration_options
    credential = client.create(challenge: options['challenge'], user_verified: true, **create_options)
    post passkeys_url, params: { credential: credential, label: label }, as: :json
  end

  test 'options returns creation options for the signed-in user and sets a webauthn_id' do
    options = registration_options

    assert_response :success
    assert_predicate options['challenge'], :present?
    assert_equal 'www.example.com', options.dig('rp', 'id')
    assert_equal @user.reload.webauthn_id, options.dig('user', 'id')
    assert_equal 'required', options.dig('authenticatorSelection', 'userVerification')
    assert_equal 'required', options.dig('authenticatorSelection', 'residentKey')
  end

  test 'options excludes passkeys the user already registered' do
    register
    options = registration_options

    assert_equal [Passkey.last.external_id], options['excludeCredentials'].pluck('id')
  end

  test 'create stores the passkey with the given label' do
    assert_difference -> { @user.passkeys.count }, 1 do
      register(label: 'Work phone')
    end

    assert_response :created
    passkey = @user.passkeys.last
    assert_equal 'Work phone', passkey.label
    assert_predicate passkey.public_key, :present?
  end

  test 'create falls back to a default label when none is given' do
    register(label: '')

    assert_response :created
    assert_match(/\APasskey/, @user.passkeys.last.label)
  end

  test 'create rejects a replayed challenge' do
    options = registration_options
    credential = @client.create(challenge: options['challenge'], user_verified: true)
    post passkeys_url, params: { credential: credential }, as: :json
    assert_response :created

    assert_no_difference -> { Passkey.count } do
      post passkeys_url, params: { credential: credential }, as: :json
    end
    assert_response :unprocessable_entity
  end

  test 'create rejects a credential from the wrong origin' do
    assert_no_difference -> { Passkey.count } do
      register(client: WebAuthn::FakeClient.new('https://evil.example.com'))
    end

    assert_response :unprocessable_entity
  end

  test 'create rejects an authenticator that did not verify the user' do
    options = registration_options
    credential = @client.create(challenge: options['challenge'], user_verified: false)

    assert_no_difference -> { Passkey.count } do
      post passkeys_url, params: { credential: credential }, as: :json
    end
    assert_response :unprocessable_entity
  end

  test 'create without a prior options request is rejected' do
    credential = @client.create(challenge: Base64.urlsafe_encode64('x' * 32, padding: false), user_verified: true)

    assert_no_difference -> { Passkey.count } do
      post passkeys_url, params: { credential: credential }, as: :json
    end
    assert_response :unprocessable_entity
  end

  test 'destroy removes the signed-in user\'s passkey' do
    register
    passkey = @user.passkeys.last

    assert_difference -> { Passkey.count }, -1 do
      delete passkey_url(passkey)
    end
    assert_redirected_to edit_user_registration_url
  end

  test 'destroy cannot remove another user\'s passkey' do
    other = users(:brooke).passkeys.create!(external_id: 'other', public_key: 'k', label: 'Theirs')

    assert_no_difference -> { Passkey.count } do
      delete passkey_url(other)
    end
    assert_response :not_found
  end

  test 'requires sign in' do
    sign_out @user

    post options_passkeys_url, as: :json

    assert_response :unauthorized
  end
end
