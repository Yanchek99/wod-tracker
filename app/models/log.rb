class Log < ApplicationRecord
  belongs_to :user, default: -> { Current.user }
  belongs_to :workout
  has_one :metric, as: :measurable, dependent: :destroy
  has_many :exercises, through: :workout
  has_many :movements, -> { distinct }, through: :exercises
  has_many :movement_logs, dependent: :destroy

  accepts_nested_attributes_for :metric
  accepts_nested_attributes_for :movement_logs, allow_destroy: true

  validates :user, :workout, :metric, presence: true

  def build_movement_logs
    exercises.each do |e|
      ml = movement_logs.build(movement: e.movement)
      e.metrics.each do |m|
        ml.metrics.build(measurement: m.measurement, value: m.calculated_value(e.segment.presence || e.workout))
      end
    end
  end
end
