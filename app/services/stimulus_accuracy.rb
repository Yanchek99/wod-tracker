# How close the calculator comes to what CrossFit actually posted (config/stimulus_claims.yml):
# finish-window overlap, a stated-vs-calculated loading confusion matrix, sets-guide agreement,
# per-movement time ceilings, and the workouts it misses worst. Reads only the database, the
# reference table and the claims file.
class StimulusAccuracy
  Report = Data.define(:matched, :unmatched, :time, :result, :round, :rounds, :percent, :loading, :sets, :duration, :worst)

  # Stated [low, high] windows => the calculated fields they are checked against.
  WINDOWS = {
    time: ['finish_seconds', %i[stimulus_range_low stimulus_range_high]],
    # An expected result in the workout's own score unit (seconds, reps, rounds), e.g. a public
    # Open leaderboard's percentile band.
    result: ['result', %i[stimulus_range_low stimulus_range_high]],
    round: ['round_seconds', %i[stimulus_round_seconds_low stimulus_round_seconds_high]],
    rounds: ['rounds', %i[stimulus_range_low stimulus_range_high]],
    percent: ['percent_1rm', %i[stimulus_percent_1rm_low stimulus_percent_1rm_high]]
  }.freeze

  def self.call(claims = StimulusClaims.load, reference = StimulusReference.current)
    new(claims, reference).call
  end

  # Plain-text lines for the rake task and the RailsAdmin stimulus tools page.
  def self.summary(report) = Summary.lines(report)

  def initialize(claims, reference)
    @claims = claims
    @reference = reference
  end

  def call
    workouts = claimed_workouts
    @rows = @claims.filter_map { |claim| (workout = workouts[claim.workout_name]) && compare(claim, workout) }
    windows = WINDOWS.transform_values { |claim_key, fields| window_summary(claim_key, fields) }
    Report.new(matched: @rows.size, unmatched: @claims.size - @rows.size, **windows,
               loading: loading_matrix, sets: sets_summary, duration: duration_summary, worst: worst)
  end

  private

  def claimed_workouts
    Workout.where(name: @claims.map(&:workout_name)).includes(segments: { exercises: :movement }).index_by(&:name)
  end

  def compare(claim, workout)
    calculated = StimulusCalculator.workout(workout, @reference)
    exercises = workout.segments.flat_map(&:exercises).index_by { |exercise| exercise.movement.name }
    {
      workout: workout.name, claims: claim.claims,
      calculated:, range: calculated.values_at(:stimulus_range_low, :stimulus_range_high),
      movements: exercises.transform_values { |exercise| StimulusCalculator.exercise(exercise, @reference) }
    }
  end

  def window_summary(claim_key, fields)
    compared = @rows.filter_map do |row|
      stated = row[:claims][claim_key]
      calculated = row[:calculated].values_at(*fields)
      [stated, calculated] if stated && calculated.any?
    end
    gaps = compared.map { |stated, calculated| window_gap(stated, calculated) }
    { overlap: gaps.count(0), compared: compared.size, median_gap: median(gaps) }
  end

  # Distance between the stated and calculated windows (nil bound = open); 0 when they overlap.
  def window_gap(stated, calculated)
    stated_low, stated_high = stated
    calc_low, calc_high = calculated
    [(stated_low || 0) - (calc_high || calc_low), (calc_low || calc_high) - (stated_high || Float::INFINITY), 0].max.round
  end

  def gap(row)
    window_gap(row[:claims]['finish_seconds'], row[:range])
  end

  def loading_matrix
    pairs = movement_pairs('loading', :stimulus_loading)
    pairs.each_with_object(Hash.new { |hash, key| hash[key] = Hash.new(0) }) do |(stated, calculated), matrix|
      matrix[stated][calculated || 'blank'] += 1
    end
  end

  def sets_summary
    pairs = movement_pairs('sets_max', :stimulus_sets_max).select(&:last)
    { exact: pairs.count { |stated, calc| stated == calc },
      within_one: pairs.count { |stated, calc| (stated - calc).abs <= 1 }, compared: pairs.size }
  end

  def duration_summary
    pairs = movement_pairs('duration_max', :stimulus_duration_max).select(&:last)
    { compared: pairs.size, median_gap_seconds: median(pairs.map { |stated, calc| (stated - calc).abs }) }
  end

  # [stated, calculated] for every movement claim of this kind.
  def movement_pairs(claim_key, field)
    @rows.flat_map do |row|
      row[:claims].fetch(claim_key, {}).map { |name, stated| [stated, row[:movements][name]&.dig(field)] }
    end
  end

  def worst
    @rows.select { |row| row[:claims]['finish_seconds'] && row[:range].last }
         .map { |row| { workout: row[:workout], gap_seconds: gap(row), stated: row[:claims]['finish_seconds'], calculated: row[:range] } }
         .select { |miss| miss[:gap_seconds].positive? }
         .max_by(10) { |miss| miss[:gap_seconds] }
  end

  def median(values)
    return if values.empty?

    sorted = values.sort
    sorted[sorted.size / 2]
  end
end
