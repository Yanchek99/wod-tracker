require 'test_helper'

module OpenLeaderboard
  class ClientTest < ActiveSupport::TestCase
    test 'fetches a men Rx page sorted by the workout, once per page' do
      request = stub_request(:get, 'https://c3po.crossfit.com/api/leaderboards/v2/competitions/open/2018/leaderboards')
                .with(query: { view: '0', division: '1', scaled: '0', sort: '3', page: '2' })
                .to_return(status: 200, body: { leaderboardRows: [] }.to_json)
      client = OpenLeaderboard::Client.new(pause: 0)

      2.times { assert_equal({ 'leaderboardRows' => [] }, client.page(2018, 3, 2)) }

      assert_requested request, times: 1
    end
  end
end
