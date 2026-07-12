require 'simplecov'
SimpleCov.start

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'webmock/minitest'

# Disable outbound HTTP in tests; localhost stays open for Capybara/Selenium.
WebMock.disable_net_connect!(allow_localhost: true)

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    CF_WORKOUT_FIXTURES = Rails.root.join('test/fixtures/cf_workout')

    def cf_workout_fixture(name)
      File.read(CF_WORKOUT_FIXTURES.join(name))
    end

    def stub_cf_workout_redirect(legacy_path, slug)
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/#{legacy_path}})
        .to_return(status: 301, headers: { 'Location' => "/#{slug}" })
    end
  end
end
