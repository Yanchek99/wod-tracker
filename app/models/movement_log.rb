class MovementLog < ApplicationRecord
  belongs_to :log
  belongs_to :movement
  belongs_to :measurement

  before_validation :set_measurement_value_to_reps, if: proc { |ml| ml.measurement.rep? }

  validates :log, :reps, :movement, :measurement, :measurement_value, presence: true
  validates :reps, numericality: { greater_than: 0 }

  def set_measurement_value_to_reps
    self.measurement_value = reps
  end
end
