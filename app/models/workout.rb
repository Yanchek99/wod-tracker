class Workout < ApplicationRecord
  has_many :exercises

  def objective_message
    return "#{rounds} rounds for time" if rounds_for_time?
    return "As many rounds as possible in #{time} minutes" if amrap?
    return "EMOM #{time}" if emom?
    return "#{rounds} #{time}-minute rounds" if timed_rounds?
    interval
  end

  def rounds_for_time?
    rounds.present? && time.nil? && interval.nil?
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
end
