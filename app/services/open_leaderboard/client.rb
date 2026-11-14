require 'net/http'

module OpenLeaderboard
  # Reads pages of the public Open leaderboard JSON (men's Rx, sorted by one workout), caching each
  # page and pausing between requests to stay polite to games.crossfit.com.
  class Client
    URL = 'https://c3po.crossfit.com/api/leaderboards/v2/competitions/open/%<year>d/leaderboards'.freeze
    MEN = '1'.freeze

    def initialize(pause: 0.5)
      @pause = pause
      @pages = {}
    end

    def page(year, ordinal, number)
      @pages[[year, ordinal, number]] ||= fetch(year, ordinal, number)
    end

    private

    def fetch(year, ordinal, number)
      uri = URI(format(URL, year:))
      uri.query = URI.encode_www_form(view: 0, division: MEN, scaled: 0, sort: ordinal, page: number)
      response = Net::HTTP.get_response(uri, 'User-Agent' => 'WOD-Tracker/1.0')
      raise "Open leaderboard #{year} column #{ordinal} page #{number}: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      sleep @pause
      JSON.parse(response.body)
    end
  end
end
