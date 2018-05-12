class Exercise < ApplicationRecord
  belongs_to :movement

  def reps?
    reps > 1
  end

  def can_rx?
    male_rx.present? || female_rx.present?
  end
end
