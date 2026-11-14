require 'test_helper'

class OpenLeaderboardTest < ActiveSupport::TestCase
  # A fake leaderboard sorted by one workout: rx_scores Rx scores (best first), then scaled, then blanks.
  class FakeClient
    PAGE = 50

    attr_reader :requests

    def initialize(rx_scores:, scaled: 30, blank: 20, valid: '1')
      @rows = Array.new(rx_scores) { |index| row(yield(index), '0', valid) } +
              Array.new(scaled) { row('100 reps - s', '1', '1') } + Array.new(blank) { row('', '0', '') }
      @requests = 0
    end

    def page(_year, _ordinal, number)
      @requests += 1
      rows = @rows.slice((number - 1) * PAGE, PAGE) || []
      { 'pagination' => { 'totalPages' => (@rows.size / PAGE.to_f).ceil }, 'leaderboardRows' => rows }
    end

    private

    def row(display, scaled, valid)
      { 'scores' => [{ 'ordinal' => 1, 'scoreDisplay' => display, 'scaled' => scaled, 'valid' => valid }] }
    end
  end

  test 'parses score displays' do
    assert_equal [:seconds, 224], OpenLeaderboard.parse('3:44', 'time')
    assert_equal [:seconds, 3723], OpenLeaderboard.parse('1:02:03', 'time')
    assert_equal [:reps, 487], OpenLeaderboard.parse('487 reps', 'rep')
    assert_equal [:load, 292], OpenLeaderboard.parse('292 lb', 'weight')
    assert_nil OpenLeaderboard.parse('', 'rep')
    assert_nil OpenLeaderboard.parse('CAP+ 12', 'time')
  end

  # The early Opens show a bare number: reps on a rep-scored workout, pounds on a load-scored one.
  test 'reads a bare number by the workout score type' do
    assert_equal [:reps, 396], OpenLeaderboard.parse('396', 'rep')
    assert_equal [:load, 225], OpenLeaderboard.parse('225', 'weight')
  end

  # 230 Rx scores of 600 - i reps: the 95th percentile is rank 12 (589 reps), the 80th rank 46 (555).
  test 'picks the 80th and 95th percentile of Rx scores as a reps window' do
    client = FakeClient.new(rx_scores: 230) { |i| "#{600 - i} reps" }

    assert_equal({ 'result' => [555, 589] }, OpenLeaderboard::Column.new(2018, 1, client).claim('rep'))
  end

  # Faster is better for a time: the 95th percentile is the low end.
  test 'a time-scored workout gives a seconds window' do
    client = FakeClient.new(rx_scores: 230) { |i| format('%<m>d:%<s>02d', m: (300 + i) / 60, s: (300 + i) % 60) }

    assert_equal({ 'result' => [311, 345] }, OpenLeaderboard::Column.new(2018, 1, client).claim('time'))
  end

  test 'a capped athlete at a percentile leaves that end open' do
    client = FakeClient.new(rx_scores: 230) { |i| i < 30 ? format('%<m>d:%<s>02d', m: 9, s: i) : "#{200 - i} reps" }

    assert_equal({ 'result' => [551, nil] }, OpenLeaderboard::Column.new(2018, 1, client).claim('time'))
  end

  test 'a time-scored workout where both percentiles capped gives no claim' do
    client = FakeClient.new(rx_scores: 230) { |i| "#{200 - i} reps" }

    assert_nil OpenLeaderboard::Column.new(2018, 1, client).claim('time')
  end

  test 'knows each seeded Open workout score type' do
    assert_equal 'rep', OpenLeaderboard.seeded_score_types['Open 18.1']
    assert_equal 'weight', OpenLeaderboard.seeded_score_types['Open 18.2a']
  end

  # The 2012 leaderboard leaves `valid` blank on every score.
  test 'scores with a blank valid flag still count as Rx' do
    client = FakeClient.new(rx_scores: 230, valid: '') { |i| (600 - i).to_s }

    assert_equal({ 'result' => [555, 589] }, OpenLeaderboard::Column.new(2012, 1, client).claim('rep'))
  end

  test 'a load-scored workout gives no claim' do
    client = FakeClient.new(rx_scores: 230) { |i| "#{300 - i} lb" }

    assert_nil OpenLeaderboard::Column.new(2018, 1, client).claim('weight')
  end

  test 'maps each leaderboard column to the seeded workout name' do
    assert_equal 'Open 18.2a', OpenLeaderboard.workout_name(2018, 3)
    assert_equal 'Open 23.2B', OpenLeaderboard.workout_name(2023, 3)
    assert_equal 'Open 15.1a', OpenLeaderboard.workout_name(2015, 2)
  end

  test 'every mapped name that exists is a seeded workout' do
    seeded = Rails.root.join('db/seeds/open_workouts.rb').read.scan(/find_or_create_by\(name: '([^']+)'\)/).flatten

    mapped = OpenLeaderboard::COLUMNS.flat_map { |year, labels| labels.each_index.map { |i| OpenLeaderboard.workout_name(year, i + 1) } }

    assert_operator (mapped & seeded).size, :>=, 50
  end
end
