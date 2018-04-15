class Log < ApplicationRecord
  belongs_to :user, default: -> { Current.user }
  belongs_to :workout
  has_many :exercises, through: :workout
  has_many :movements, through: :exercises

  has_many :movement_logs, dependent: :destroy
  accepts_nested_attributes_for :movement_logs, allow_destroy: true

  validates :user, :workout, :measurement_value, presence: true

  def build_movement_logs
    exercises.group(:movement_id).each do |e|
      movement_logs.build(movement: e.movement, measurement_value: e.male_rx) unless e.movement.measurement.nil?
    end
  end

end
