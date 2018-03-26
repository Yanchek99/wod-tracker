class Exercise < ApplicationRecord
  belongs_to :movement

  def measurement_message
    "#{measurement_value} #{measurement} " if show_measurement?
  end

  def has_reps?
    reps > 1
  end

  def show_measurement?
    return false if measurement_value.nil?
    return true if measurement_value.eql?('max')
    true
  end

  def can_rx?
     male_rx.present? || female_rx.present?
  end
end
