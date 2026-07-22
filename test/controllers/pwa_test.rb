require 'test_helper'

class PwaTest < ActionDispatch::IntegrationTest
  # No `sign_in` here on purpose. Browsers fetch the manifest without credentials, so if
  # ApplicationController's `authenticate_user!` ever applied to this route the app would become
  # silently uninstallable -- no exception, no log line, just a browser that stops offering
  # "Install". This test is that regression guard.
  test 'manifest is reachable without signing in' do
    get pwa_manifest_url

    assert_response :success
  end

  test 'manifest declares the fields browsers require to offer installation' do
    get pwa_manifest_url
    manifest = response.parsed_body

    assert_equal 'WOD Tracker', manifest['name']
    assert_equal '/', manifest['start_url']
    assert_equal 'standalone', manifest['display']
    assert_equal %w[192x192 512x512], manifest['icons'].pluck('sizes').uniq.sort
  end

  test 'manifest offers a maskable icon so Android launchers can crop it to any shape' do
    get pwa_manifest_url
    icons = response.parsed_body['icons']

    assert_includes icons.pluck('purpose'), 'maskable'
  end
end
