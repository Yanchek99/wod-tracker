class Exercise < ApplicationRecord
  belongs_to :movement

  def reps?
    reps > 1
  end

  def can_rx?
    male_rx.present? || female_rx.present?
  end

  def suggested_measurement_value
    return measurement_value if measurement_value.present?
    return male_rx if male_rx
    return female_rx if female_rx
    nil
  end
end
