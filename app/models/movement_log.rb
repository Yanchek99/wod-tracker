class MovementLog < ApplicationRecord
  include MovementLogPerformance

  belongs_to :log
  belongs_to :movement

  SET_BREAKDOWN_TEXT_PATTERN = /\A[\d,\-\s]*\z/

  # Reps-per-set input for the recording form, comma- or dash-separated, e.g. "8,7,6" or
  # "10,10,8-2" -> [8, 7, 6] / [10, 10, 8, 2]. Commas and dashes are equivalent separators --
  # the stored set_breakdown column has no round-boundary concept, so a dash exists purely to let
  # the athlete group entries by round while typing (e.g. "8-2" for one round broken into two
  # sets); it has no effect on what's actually stored. Blank pieces between/around separators
  # (double commas, trailing dashes, stray whitespace) are dropped rather than treated as
  # malformed input, since a typo shouldn't block an otherwise-valid entry.
  def set_breakdown_text=(value)
    @set_breakdown_text_input = value.to_s
    self.set_breakdown = @set_breakdown_text_input.split(/[,-]/).map(&:strip).compact_blank.map(&:to_i)
  end

  def set_breakdown_text
    set_breakdown.presence&.join(', ')
  end

  # True when set_breakdown_text= was called this request with a genuinely non-blank value --
  # i.e. the athlete actually typed something into a visible field, as opposed to a hidden field
  # submitting blank, or reps having been set directly without touching this field at all (e.g.
  # a request-level score calculation, or a test). Used by Log#resync_trivial_set_breakdown to
  # tell "safe to auto-derive" apart from "must be preserved for normal validation to judge."
  def set_breakdown_text_submitted?
    @set_breakdown_text_input.present?
  end

  attr_writer :set_breakdown_target_reps

  def set_breakdown_target_reps
    @set_breakdown_target_reps || reps.to_i
  end

  before_validation :compact_set_breakdown

  validate :set_breakdown_sums_to_reps
  validate :set_breakdown_values_are_positive
  validate :set_breakdown_text_format

  # Chunks the flat set_breakdown array into rounds, using round sizes reconstructed from the
  # workout's structure (see Log#round_sizes_for_set_breakdown) -- [] if nothing was captured,
  # or a single round containing everything when no round structure is knowable for this
  # movement. Greedily accumulates entries into each round's bucket until their sum reaches that
  # round's target; a set is assumed to never span a round boundary.
  def set_breakdown_rounds
    return [] if set_breakdown.blank?

    round_sizes = log.round_sizes_for_set_breakdown(self)
    return [set_breakdown] if round_sizes.blank?

    chunk_set_breakdown_by_round(round_sizes)
  end

  # The largest rep count this movement log can actually back up as one continuous, unbroken
  # effort -- nil when that can't be verified. Three cases are unbroken by construction, not
  # self-report: reps <= 1 (a single rep, or the app's "max effort" reps: 0 sentinel, can't be
  # broken into sets); a set-based lifting day (Workout#set_based_lifting? -- a fixed "5x5" or a
  # variable build like "5-5-3-3-1-1"); and a single max-effort achievement test
  # (Workout#single_achievement_test? -- a bare "Max Pull-up"-style test, where going until
  # failure in one continuous attempt is what the test *is*). Each of those proofs comes from
  # workout structure that already exists for every log, old or new, so none of them need a
  # captured set_breakdown to trust reps directly. Anything else needs a captured set_breakdown,
  # and the largest entry in it is the real rep-max, not the raw (possibly WOD-aggregated) reps
  # total -- e.g. Diane's Deadlift logs reps: 45 (21+15+9 summed by Metric#calculated_value) but
  # set_breakdown: [21, 15, 9], so the verified rep-max is 21.
  def verified_unbroken_reps
    return if reps.blank?
    return reps if reps <= 1 || log.workout.set_based_lifting? || log.workout.single_achievement_test?

    set_breakdown.presence&.max
  end

  private

  def compact_set_breakdown
    self.set_breakdown = set_breakdown.compact if set_breakdown
  end

  def chunk_set_breakdown_by_round(round_sizes)
    remaining = set_breakdown.dup
    rounds = round_sizes.filter_map { |target| take_round_chunk(remaining, target) }
    rounds << remaining if remaining.any?
    rounds
  end

  def take_round_chunk(remaining, target)
    chunk = []
    sum = 0
    while sum < target && remaining.any?
      value = remaining.shift
      chunk << value
      sum += value
    end
    chunk if chunk.any?
  end

  def set_breakdown_sums_to_reps
    return if set_breakdown.blank?
    return if set_breakdown.sum == set_breakdown_target_reps

    errors.add(:set_breakdown, 'must sum to reps')
  end

  def set_breakdown_values_are_positive
    return if set_breakdown.blank?
    return if set_breakdown.all? { |size| size.to_i.positive? }

    errors.add(:set_breakdown, 'must contain only positive numbers')
  end

  def set_breakdown_text_format
    return if @set_breakdown_text_input.blank?
    return if @set_breakdown_text_input.match?(SET_BREAKDOWN_TEXT_PATTERN)

    errors.add(:set_breakdown_text, 'can only contain numbers, commas, dashes, and spaces')
  end
end
