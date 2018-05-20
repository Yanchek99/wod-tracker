class Log < ApplicationRecord
  belongs_to :user, default: -> { Current.user }
  belongs_to :workout
  has_many :exercises, through: :workout
  has_many :movements, -> { distinct }, through: :exercises

  has_many :movement_logs, dependent: :destroy
  accepts_nested_attributes_for :movement_logs, allow_destroy: true

  validates :user, :workout, :measurement_value, presence: true

  def build_movement_logs
    exercises.to_a.uniq!(&:movement).each do |e|
      movement_logs.build(movement: e.movement, measurement: e.measurement, measurement_value: e.suggested_measurement_value)
    end
  end
end
