require 'test_helper'

module CfWod
  class FetcherTest < ActiveSupport::TestCase
    FIXTURES = Rails.root.join('test/fixtures/cf_wod')
    SHELL_HTML = '<html><body><div id="root"></div></body></html>'.freeze

    def fixture(name)
      File.read(FIXTURES.join(name))
    end

    def stub_redirect(legacy_path, slug)
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/#{legacy_path}})
        .to_return(status: 301, headers: { 'Location' => "/#{slug}" })
    end

    test 'fetches a modern-template WOD reached via redirect, re-requesting with a fresh cache-buster' do
      stub_redirect('2025/06/18', '250618')
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/250618}).to_return(status: 200, body: fixture('modern_normal.html'))

      page = Fetcher.call(Date.new(2025, 6, 18))

      assert_equal '250618', page.slug
      assert_includes page.body_text, 'front squats'
      assert_includes page.body_text, 'thrusters'
      assert page.description.present?
      assert_includes page.scaling, 'Intermediate option'
      assert_includes page.scaling, 'Beginner option'
      assert_not_includes page.scaling, 'Resources'
      assert_not_includes page.scaling, 'Find a gym near you'
      assert_not page.rest_day?
      assert_equal '250617', page.previous_slug
      assert_equal '250619', page.next_slug

      assert_requested(:get, %r{\Ahttps://www\.crossfit\.com/250618}) do |request|
        request.uri.query.to_s.start_with?('_=')
      end
    end

    test 'fetches a modern-template multi-part WOD, with scaling detected despite no "Scaling" heading' do
      stub_redirect('2026/06/20', '260620')
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/260620}).to_return(status: 200, body: fixture('modern_multi_part.html'))

      page = Fetcher.call(Date.new(2026, 6, 20))

      assert_includes page.body_text, 'sled drag'
      assert_includes page.body_text, 'bent-over rows'
      assert_not page.rest_day?
      assert_equal '260619', page.previous_slug
      assert_equal '260621', page.next_slug

      assert_includes page.description, 'Stimulus and Strategy'
      assert_not_includes page.description, 'Intermediate option'
      assert_includes page.scaling, 'Intermediate option'
      assert_includes page.scaling, 'Beginner option'
      assert_not_includes page.scaling, 'Resources'
      assert_not_includes page.scaling, 'Find a gym near you'
    end

    test 'retries when the modern route server-renders a content-less shell' do
      stub_redirect('2026/06/20', '260620')
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/260620}).to_return(
        { status: 200, body: SHELL_HTML },
        { status: 200, body: fixture('modern_multi_part.html') }
      )

      page = Fetcher.call(Date.new(2026, 6, 20))

      assert_includes page.body_text, 'sled drag'
    end

    test 'raises FetchError when the modern route keeps server-rendering a content-less shell' do
      stub_redirect('2026/06/20', '260620')
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/260620}).to_return(status: 200, body: SHELL_HTML)

      assert_raises(Fetcher::UnrecognizedTemplateError) do
        Fetcher.call(Date.new(2026, 6, 20))
      end
    end

    test 'detects a modern-template rest day' do
      stub_redirect('2026/07/02', '260702')
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/260702}).to_return(status: 200, body: fixture('modern_rest_day.html'))

      page = Fetcher.call(Date.new(2026, 7, 2))

      assert page.rest_day?
    end

    test 'fetches a legacy-template WOD with inline scaling' do
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2018/01/10}).to_return(status: 200, body: fixture('legacy_with_scaling.html'))

      page = Fetcher.call(Date.new(2018, 1, 10))

      assert_equal '180110', page.slug
      assert_includes page.body_text, 'power snatches'
      assert_includes page.scaling, 'Intermediate Option'
      assert_includes page.scaling, 'Beginner Option'
      assert_not page.rest_day?
      assert_equal '180109', page.previous_slug
      assert_equal '180111', page.next_slug
    end

    test 'raises FetchError on a non-success, non-redirect response' do
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2030/01/01}).to_return(status: 404)

      assert_raises(Fetcher::FetchError) { Fetcher.call(Date.new(2030, 1, 1)) }
    end

    test 'raises FetchError on a network timeout' do
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2030/01/02}).to_timeout

      assert_raises(Fetcher::FetchError) { Fetcher.call(Date.new(2030, 1, 2)) }
    end

    test 'raises FetchError when redirects exceed the max' do
      stub_redirect('2030/01/03', 'loop')
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/loop}).to_return(status: 301, headers: { 'Location' => '/loop' })

      assert_raises(Fetcher::FetchError) { Fetcher.call(Date.new(2030, 1, 3)) }
    end
  end
end
