class MovementLog < ApplicationRecord
  include MovementLogPerformance

  belongs_to :log
  belongs_to :movement

  before_validation :compact_set_breakdown

  validate :set_breakdown_sums_to_reps
  validate :set_breakdown_values_are_positive

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
end
