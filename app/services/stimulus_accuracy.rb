# How close the calculator comes to what CrossFit actually posted (config/stimulus_claims.yml):
# finish-window overlap, a stated-vs-calculated loading confusion matrix, sets-guide agreement,
# per-movement time ceilings, and the workouts it misses worst. Reads only the database, the
# reference table and the claims file.
class StimulusAccuracy
  Report = Data.define(:matched, :unmatched, :time, :loading, :sets, :duration, :worst)

  def self.call(claims = StimulusClaims.load, reference = StimulusReference.current)
    new(claims, reference).call
  end

  # Plain-text lines for the rake task and the RailsAdmin stimulus tools page.
  def self.summary(report)
    [
      "#{report.matched} claimed workout(s) matched, #{report.unmatched} not in this database",
      time_line(report.time), *loading_lines(report.loading), sets_line(report.sets),
      "Time ceilings compared: #{report.duration[:compared]} (median gap #{report.duration[:median_gap_seconds] || 0} s)",
      *report.worst.map { |miss| "Miss: #{miss[:workout]} stated #{miss[:stated].inspect}, calculated #{miss[:calculated].inspect}" }
    ]
  end

  def self.time_line(time)
    "Finish window overlaps CrossFit's: #{time[:overlap]} of #{time[:compared]} (median gap #{time[:median_gap_seconds] || 0} s)"
  end

  def self.sets_line(sets)
    "Sets guide: #{sets[:exact]} exact, #{sets[:within_one]} within one, of #{sets[:compared]}"
  end

  def self.loading_lines(matrix)
    matrix.map { |stated, row| "Loading stated #{stated}: #{row.map { |calc, n| "calculated #{calc} #{n}" }.join(', ')}" }
  end

  def initialize(claims, reference)
    @claims = claims
    @reference = reference
  end

  def call
    workouts = claimed_workouts
    @rows = @claims.filter_map { |claim| (workout = workouts[claim.workout_name]) && compare(claim, workout) }
    Report.new(matched: @rows.size, unmatched: @claims.size - @rows.size, time: time_summary,
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
      range: calculated.values_at(:stimulus_range_low, :stimulus_range_high),
      movements: exercises.transform_values { |exercise| StimulusCalculator.exercise(exercise, @reference) }
    }
  end

  def time_summary
    compared = @rows.select { |row| row[:claims]['finish_seconds'] && row[:range].last }
    gaps = compared.map { |row| gap(row) }
    { overlap: gaps.count(0), compared: compared.size, median_gap_seconds: median(gaps) }
  end

  # Seconds between the stated and calculated windows; 0 when they overlap.
  def gap(row)
    stated_low, stated_high = row[:claims]['finish_seconds']
    calc_low, calc_high = row[:range]
    [(stated_low || 0) - calc_high, calc_low - (stated_high || Float::INFINITY), 0].max.round
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
