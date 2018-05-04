class Exercise < ApplicationRecord
  belongs_to :movement

  def has_reps?
    reps > 1
  end

  def can_rx?
     male_rx.present? || female_rx.present?
  end
end
