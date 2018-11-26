class Log < ApplicationRecord
  belongs_to :user, default: -> { Current.user }
  belongs_to :workout
  has_many :exercises, through: :workout
  has_many :movements, -> { distinct }, through: :exercises

  has_many :exercise_logs, as: :assignable, dependent: :destroy
  accepts_nested_attributes_for :exercise_logs, allow_destroy: true

  validates :user, :workout, :measurement_value, presence: true

  def build_exercise_logs
    exercises.each do |e|
      exercise_logs.build(e.copyable_attributes)
    end
  end
end
