class Exercise < ApplicationRecord
  belongs_to :workout
  belongs_to :movement
  belongs_to :measurement
  has_many :metrics

  accepts_nested_attributes_for :metrics, allow_destroy: true

  # before_validation :set_measurement_from_movement, unless: proc { |e| e.measurement_d.present? }

  # validates :movement, presense: true

  def can_rx?
    male_rx.present? || female_rx.present?
  end

  def suggested_measurement_value
    return measurement_value if measurement_value.present?
    return male_rx if male_rx
    return female_rx if female_rx
    return total_expected_reps if measurement.rep?
    nil
  end

  def total_expected_reps
    return workout.reps_from_interval if workout.interval?
    return nil unless reps # Reps can be nil to signify max
    return reps if workout.rounds.nil? || workout.rounds&.zero?
    reps * workout.rounds
  end

  # def set_measurement_from_movement
  #   self.measurement_id = movement.measurement
  # end
end
