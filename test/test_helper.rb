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

    CF_WOD_FIXTURES = Rails.root.join('test/fixtures/cf_wod')

    def cf_wod_fixture(name)
      File.read(CF_WOD_FIXTURES.join(name))
    end

    def stub_cf_wod_redirect(legacy_path, slug)
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/#{legacy_path}})
        .to_return(status: 301, headers: { 'Location' => "/#{slug}" })
    end

    # Object#stub (from minitest/mock) isn't available here -- minitest 6 dropped mock.rb into a
    # separate minitest-mock gem this app doesn't depend on -- so stub WorkoutExtraction::LlmParser.call
    # by hand: swap in a replacement singleton method for the duration of the block, then restore the
    # original. `result` may be a plain value to return (e.g. a persisted Workout fixture) or a
    # callable (e.g. a lambda that raises) to invoke with the same arguments the job passes.
    def stub_llm_parser(result)
      original_call = WorkoutExtraction::LlmParser.method(:call)
      responder = result.respond_to?(:call) ? result : ->(*) { result }
      WorkoutExtraction::LlmParser.define_singleton_method(:call) { |*args, **kwargs| responder.call(*args, **kwargs) }
      yield
    ensure
      WorkoutExtraction::LlmParser.define_singleton_method(:call, original_call)
    end
  end
end
