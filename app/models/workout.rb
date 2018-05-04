class Workout < ApplicationRecord
  enum measurement: [:reps, :rounds, :weight, :time, :calories]

  has_many :exercises, dependent: :destroy
  has_many :movements, through: :exercises
  has_many :logs, dependent: :destroy
  has_many :movement_logs, through: :logs

  accepts_nested_attributes_for :exercises, allow_destroy: true

  def rounds_for_time?
    rounds.present? && time.blank? && interval.blank?
  end

  def amrap?
    time.present? && rounds.blank? && interval.blank?
  end

  def emom?
    time.present? && rounds.present? && time.eql?(rounds)
  end

  def timed_rounds?
    rounds.present? && time.present? && interval.nil?
  end

  def logged?(user)
    logs.where(user: user)
  end

  def measurement_message
    return measurement if measurement
    return 'minutes' if rounds_for_time?
    return 'rounds' if amrap?
    'weight'
  end
end
