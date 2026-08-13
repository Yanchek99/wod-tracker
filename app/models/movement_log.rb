class MovementLog < ApplicationRecord
  include MovementLogPerformance

  belongs_to :log
  belongs_to :movement

  SET_BREAKDOWN_TEXT_PATTERN = /\A[\d,\s]*\z/

  # Comma-separated reps-per-set input for the recording form, e.g. "8,7,6" -> [8, 7, 6]. Blank
  # pieces between/around commas (double commas, trailing commas, stray whitespace) are dropped
  # rather than treated as malformed input, since a typo shouldn't block an otherwise-valid entry.
  def set_breakdown_text=(value)
    @set_breakdown_text_input = value.to_s
    self.set_breakdown = @set_breakdown_text_input.split(',').map(&:strip).compact_blank.map(&:to_i)
  end

  def set_breakdown_text
    set_breakdown.presence&.join(', ')
  end

  before_validation :compact_set_breakdown

  validate :set_breakdown_sums_to_reps
  validate :set_breakdown_values_are_positive
  validate :set_breakdown_text_format

  private

  def compact_set_breakdown
    self.set_breakdown = set_breakdown.compact if set_breakdown
  end

  def set_breakdown_sums_to_reps
    return if set_breakdown.blank?
    return if set_breakdown.sum == reps.to_i

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

    errors.add(:set_breakdown_text, 'can only contain numbers, commas, and spaces')
  end
end
