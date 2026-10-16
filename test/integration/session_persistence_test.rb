require 'test_helper'

# Regression coverage for the PWA session-timeout fix: without a persistent session cookie,
# iOS/Android killing the backgrounded PWA process drops the (expiry-less) session cookie and
# forces a re-login. See config/initializers/session_store.rb.
class SessionPersistenceTest < ActionDispatch::IntegrationTest
  test 'session_options configures a persistent, rolling cookie' do
    options = Rails.application.config.session_options

    assert_equal 30.days, options[:expire_after]
  end

  test 'signing in sets a session cookie that survives closing the browser' do
    user = users(:mathew)
    user.update!(password: 'password123', password_confirmation: 'password123')

    post user_session_url, params: { user: { email: user.email, password: 'password123' } }

    assert_redirected_to root_url
    set_cookie = response.headers['Set-Cookie']
    session_cookie = set_cookie.lines.find { |line| line.start_with?('_wod_tracker_session=') }

    assert session_cookie, "expected a _wod_tracker_session cookie, got: #{set_cookie}"
    assert_match(/expires=/i, session_cookie, 'session cookie should carry an expiry, not be a session-only cookie')
  end
end
