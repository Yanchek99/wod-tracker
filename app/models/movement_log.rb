class MovementLog < ApplicationRecord
  include MovementLogPerformance

  belongs_to :log
  belongs_to :movement

  validate :set_breakdown_sums_to_reps

  private

  def set_breakdown_sums_to_reps
    return if set_breakdown.blank?
    return if set_breakdown.sum == reps.to_i

    errors.add(:set_breakdown, 'must sum to reps')
  end
end
