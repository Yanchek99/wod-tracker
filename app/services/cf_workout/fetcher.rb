require 'net/http'
require 'securerandom'

module CfWorkout
  class Fetcher
    class FetchError < StandardError; end
    class UnrecognizedTemplateError < FetchError; end

    MAX_REDIRECTS = 5
    MAX_EMPTY_TEMPLATE_RETRIES = 3
    OPEN_TIMEOUT = 5
    READ_TIMEOUT = 10
    USER_AGENT = 'WOD-Tracker/1.0'.freeze

    def self.call(date) = new(date).fetch

    def initialize(date)
      @date = date
    end

    # The modern (redirect-driven) page occasionally server-renders a content-less shell
    # instead of the real body even with a fresh cache-buster -- a re-fetch (itself with
    # its own fresh cache-buster) reliably gets the real content within a couple of tries.
    def fetch
      attempts = 0

      begin
        attempts += 1
        PageParser.new(date, fetch_html(legacy_url)).parse
      rescue UnrecognizedTemplateError
        retry if attempts < MAX_EMPTY_TEMPLATE_RETRIES
        raise
      end
    end

    private

    attr_reader :date

    def legacy_url
      "https://www.crossfit.com/workout/#{date.strftime('%Y/%m/%d')}"
    end

    def fetch_html(url, redirects_remaining: MAX_REDIRECTS)
      raise FetchError, "Too many redirects for #{url}" if redirects_remaining.negative?

      response = request(cache_busted(url))

      case response
      when Net::HTTPSuccess
        response.body
      when Net::HTTPRedirection
        location = response['location']
        raise FetchError, "Redirect with no Location header from #{url}" if location.blank?

        fetch_html(absolute_url(location), redirects_remaining: redirects_remaining - 1)
      else
        raise FetchError, "Unexpected response #{response.code} from #{url}"
      end
    end

    def request(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.open_timeout = OPEN_TIMEOUT
      http.read_timeout = READ_TIMEOUT

      get = Net::HTTP::Get.new(uri)
      get['User-Agent'] = USER_AGENT
      get['Cache-Control'] = 'no-cache'

      http.request(get)
    rescue Timeout::Error, SocketError, Errno::ECONNREFUSED => e
      raise FetchError, "Network error fetching #{url}: #{e.message}"
    end

    # A fresh cache-busting query param must be applied on every hop (including after
    # following a redirect) -- crossfit.com's modern pages intermittently return a
    # content-less client-rendered shell instead of the real body for a bare/cached URL.
    def cache_busted(url)
      uri = URI.parse(url)
      uri.query = "_=#{SecureRandom.hex(8)}"
      uri.to_s
    end

    def absolute_url(location)
      URI.join('https://www.crossfit.com', location).to_s
    end
  end
end
