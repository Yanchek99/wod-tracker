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
  def claim_entries(years, client:, &report)
    years.flat_map do |year|
      COLUMNS.fetch(year).each_index.filter_map { |index| entry(Column.new(year, index + 1, client), &report) }
    end
  end

  def entry(column)
    name = workout_name(column.year, column.ordinal)
    score_type = seeded_score_types[name]
    return unless score_type

    claim = column.claim(score_type)
    yield name, claim if block_given?
    claim && { 'workout' => name, 'source' => 'open_leaderboard',
               'reviewed' => "games.crossfit.com men's Rx 80th-95th percentile, fetched #{Date.current}",
               'claims' => claim }
  end

  # { seeded Open workout name => its score type }, read from the seeds file so no database is needed.
  def seeded_score_types
    @seeded_score_types ||= Rails.root.join('db/seeds/open_workouts.rb').read
                                 .split(/(?=Workout\.find_or_create_by\(name: ')/).filter_map do |block|
      name = block[/\AWorkout\.find_or_create_by\(name: '([^']+)'\)/, 1]
      [name, block[/score_type = :(\w+)/, 1]] if name
    end.to_h
  end

  # Only scores in the workout's own unit count: a time window reads fastest-first, and a
  # percentile that capped (reps on a For Time workout) leaves its end open; a reps window reads
  # best-first.
  def window(p80, p95, score_type)
    unit = score_type == 'time' ? :seconds : :reps
    ends = [p80, p95].map { |score| value_in(score, unit) }
    return if ends.none?

    { 'result' => unit == :seconds ? ends.reverse : ends }
  end

  def value_in(score, unit)
    score.last if score&.first == unit
  end

  # [kind, value]; a bare number (the early Opens) is pounds on a load-scored workout, else reps.
  def parse(display, score_type)
    text = display.to_s.strip
    return [score_type == 'weight' ? :load : :reps, text.to_i] if text.match?(/\A\d+\z/)

    clock_seconds(text) || unit_value(text)
  end

  def clock_seconds(text)
    time = text.match(/\A(?:(\d+):)?(\d+):(\d{2})\z/)
    [:seconds, (time[1].to_i * 3600) + (time[2].to_i * 60) + time[3].to_i] if time
  end

  def unit_value(text)
    if (reps = text.match(/\A(\d+) reps\z/))
      [:reps, reps[1].to_i]
    elsif (load = text.match(/\A(\d+) (?:lb|kg)\z/))
      [:load, load[1].to_i]
    end
  end
end
