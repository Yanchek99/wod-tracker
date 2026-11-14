module OpenLeaderboard
  # One Open workout's column on the men's Rx leaderboard, sorted by that workout.
  class Column
    attr_reader :year, :ordinal

    def initialize(year, ordinal, client)
      @year = year
      @ordinal = ordinal
      @client = client
    end

    # { 'result' => [low, high] } in the workout's score unit (score_type: the seeded workout's), or
    # nil when it is load-scored, nobody posted an Rx score, or both percentiles fell outside the
    # unit (e.g. capped reps on a For Time workout).
    def claim(score_type)
      return if score_type == 'weight'

      count = rx_count
      return if count.zero?

      p80, p95 = PERCENTILES.values.map { |percentile| OpenLeaderboard.parse(score_at(rank(count, percentile)), score_type) }
      OpenLeaderboard.window(p80, p95, score_type)
    end

    # 80th percentile = better than 80% of Rx scores: rank ceil(n x 0.20) from the top.
    def rank(count, percentile)
      (count * (1 - percentile)).ceil.clamp(1, count)
    end

    # How many athletes posted an Rx score on this workout: Rx scores sort first, then scaled
    # ("- s"), then blanks, so a binary search over pages finds the boundary.
    def rx_count
      last_page = page(1).dig('pagination', 'totalPages').to_i
      boundary = (1..last_page).bsearch { |number| !rx_row?(page(number)['leaderboardRows'].first) }
      full_pages = boundary ? boundary - 1 : last_page
      return 0 if full_pages.zero?

      ((full_pages - 1) * PAGE_SIZE) + page(full_pages)['leaderboardRows'].count { |row| rx_row?(row) }
    end

    private

    def page(number)
      @client.page(year, ordinal, number)
    end

    def rx_row?(row)
      score = row && score_in(row)
      score.present? && score['scaled'] == '0' && score['valid'] != '0' && score['scoreDisplay'].present?
    end

    def score_at(rank)
      score_in(page(((rank - 1) / PAGE_SIZE) + 1)['leaderboardRows'][(rank - 1) % PAGE_SIZE])['scoreDisplay']
    end

    def score_in(row)
      row['scores'].find { |score| score['ordinal'].to_i == ordinal }
    end
  end
end
