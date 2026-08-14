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

  attr_writer :set_breakdown_target_reps

  def set_breakdown_target_reps
    @set_breakdown_target_reps || reps.to_i
  end

  before_validation :compact_set_breakdown

  validate :set_breakdown_sums_to_reps
  validate :set_breakdown_values_are_positive
  validate :set_breakdown_text_format

  # Chunks the flat set_breakdown array into rounds, using round sizes reconstructed from the
  # workout's structure (see Log#set_breakdown_round_sizes_for) -- [] if nothing was captured,
  # or a single round containing everything when no round structure is knowable for this
  # movement. Greedily accumulates entries into each round's bucket until their sum reaches that
  # round's target; a set is assumed to never span a round boundary.
  def set_breakdown_rounds
    return [] if set_breakdown.blank?

    round_sizes = log.set_breakdown_round_sizes_for(self)
    return [set_breakdown] if round_sizes.blank?

    chunk_set_breakdown_by_round(round_sizes)
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
