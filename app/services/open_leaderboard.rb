# Verification claims from the public CrossFit Open leaderboard (games.crossfit.com): for each
# Open workout, the men's Rx scores at the 80th and 95th percentile of athletes who posted an Rx
# score -- the owner's chosen band for the reference athlete, since the Open is a test that
# athletes push to do Rx. Used only to check the stimulus calculator (StimulusAccuracy); never an
# input to it. Reads public JSON over HTTP; no LLM.
module OpenLeaderboard
  PERCENTILES = { low: 0.80, high: 0.95 }.freeze
  PAGE_SIZE = 50

  # Leaderboard columns per year, in order, as the Open numbered them.
  COLUMNS = {
    2011 => %w[11.1 11.2 11.3 11.4 11.5 11.6], 2012 => %w[12.1 12.2 12.3 12.4 12.5],
    2013 => %w[13.1 13.2 13.3 13.4 13.5], 2014 => %w[14.1 14.2 14.3 14.4 14.5],
    2015 => %w[15.1 15.1a 15.2 15.3 15.4 15.5], 2016 => %w[16.1 16.2 16.3 16.4 16.5],
    2017 => %w[17.1 17.2 17.3 17.4 17.5], 2018 => %w[18.1 18.2 18.2a 18.3 18.4 18.5],
    2019 => %w[19.1 19.2 19.3 19.4 19.5], 2020 => %w[20.1 20.2 20.3 20.4 20.5],
    2021 => %w[21.1 21.2 21.3 21.4], 2022 => %w[22.1 22.2 22.3], 2023 => %w[23.1 23.2A 23.2B 23.3],
    2024 => %w[24.1 24.2 24.3], 2025 => %w[25.1 25.2 25.3], 2026 => %w[26.1 26.2 26.3]
  }.freeze

  module_function

  def workout_name(year, ordinal)
    label = COLUMNS.fetch(year)[ordinal - 1]
    "Open #{label}" if label
  end

  # Claims-file entries for every seeded Open workout in `years`; yields each name and claim.
  def claim_entries(years, client:)
    years.flat_map do |year|
      COLUMNS.fetch(year).each_index.filter_map do |index|
        name = workout_name(year, index + 1)
        next unless seeded_names.include?(name)

        claim = claim(year, index + 1, client:)
        yield name, claim if block_given?
        claim && { 'workout' => name, 'source' => 'open_leaderboard',
                   'reviewed' => "games.crossfit.com men's Rx 80th-95th percentile, fetched #{Date.current}",
                   'claims' => claim }
      end
    end
  end

  def seeded_names
    @seeded_names ||= Rails.root.join('db/seeds/open_workouts.rb').read.scan(/find_or_create_by\(name: '([^']+)'\)/).flatten
  end

  # { 'result' => [low, high] } in the workout's score unit, or nil (load-scored, no Rx scores).
  def claim(year, ordinal, client:)
    rx_count = rx_count(year, ordinal, client)
    return if rx_count.zero?

    low, high = PERCENTILES.values.map { |percentile| parse(score_at(year, ordinal, rank(rx_count, percentile), client)) }
    window(low, high)
  end

  # 80th percentile = better than 80% of Rx scores: rank ceil(n x 0.20) from the top.
  def rank(count, percentile)
    (count * (1 - percentile)).ceil.clamp(1, count)
  end

  # Times read fastest-first and reps best-first; a percentile that capped (reps on a timed
  # workout) leaves its end of a time window open.
  def window(p80, p95)
    kinds = [p80, p95].compact.map(&:first).uniq
    return if kinds.empty? || kinds.include?(:load)
    return { 'result' => [p80&.last, p95&.last] } unless kinds.include?(:seconds)

    { 'result' => [seconds_of(p95), seconds_of(p80)] }
  end

  def seconds_of(score)
    score.last if score&.first == :seconds
  end

  def parse(display)
    text = display.to_s.strip
    if (time = text.match(/\A(?:(\d+):)?(\d+):(\d{2})\z/))
      [:seconds, (time[1].to_i * 3600) + (time[2].to_i * 60) + time[3].to_i]
    elsif (reps = text.match(/\A(\d+) reps\z/))
      [:reps, reps[1].to_i]
    elsif (load = text.match(/\A(\d+) (?:lb|kg)\z/))
      [:load, load[1].to_i]
    end
  end

  # How many athletes posted an Rx score on this workout: Rx scores sort first, then scaled
  # ("- s"), then blanks, so a binary search over pages finds the boundary.
  def rx_count(year, ordinal, client)
    last_page = client.page(year, ordinal, 1).dig('pagination', 'totalPages').to_i
    page = (1..last_page).bsearch { |number| !rx_row?(first_row(year, ordinal, number, client), ordinal) }
    page = page ? page - 1 : last_page
    return 0 if page.zero?

    rows = client.page(year, ordinal, page)['leaderboardRows']
    ((page - 1) * PAGE_SIZE) + rows.count { |row| rx_row?(row, ordinal) }
  end

  def first_row(year, ordinal, number, client)
    client.page(year, ordinal, number)['leaderboardRows'].first
  end

  def rx_row?(row, ordinal)
    score = row && row['scores'].find { |s| s['ordinal'].to_i == ordinal }
    score.present? && score['scaled'] == '0' && score['valid'] == '1' && score['scoreDisplay'].present?
  end

  def score_at(year, ordinal, rank, client)
    rows = client.page(year, ordinal, ((rank - 1) / PAGE_SIZE) + 1)['leaderboardRows']
    rows[(rank - 1) % PAGE_SIZE]['scores'].find { |s| s['ordinal'].to_i == ordinal }['scoreDisplay']
  end
end
