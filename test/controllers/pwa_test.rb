require 'test_helper'

class PwaTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

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

  # Guards the exact failure already in this repo's history: an icon path that exists but is a
  # 0-byte file. A manifest pointing at an empty icon fails installability with no error surfaced.
  test 'every manifest icon resolves to a non-empty file in public' do
    get pwa_manifest_url
    icons = response.parsed_body['icons']

    assert_predicate icons, :any?

    icons.each do |icon|
      path = Rails.public_path.join(icon['src'].delete_prefix('/'))

      assert_path_exists path
      assert_predicate path.size, :positive?, "#{icon['src']} is empty"
    end
  end

  test 'signed-in pages link the manifest' do
    sign_in users(:mathew)
    get root_url

    assert_response :success
    assert_select 'link[rel="manifest"][href=?]', pwa_manifest_path
    assert_select 'link[rel="apple-touch-icon"]'
  end

  test 'the signed-out sign-in page links the manifest' do
    get new_user_session_url

    assert_response :success
    assert_select 'link[rel="manifest"][href=?]', pwa_manifest_path
    assert_select 'link[rel="apple-touch-icon"]'
  end
end
