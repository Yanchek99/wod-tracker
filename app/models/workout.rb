class Workout < ApplicationRecord
  has_one :metric, as: :measurable, dependent: :destroy
  has_many :exercises, dependent: :destroy
  has_many :movements, through: :exercises
  has_many :segments, dependent: :destroy
  has_many :logs, dependent: :destroy
  has_many :movement_logs, through: :logs
  has_many :schedules, dependent: :destroy
  has_many :programs, through: :schedules

  accepts_nested_attributes_for :metric
  accepts_nested_attributes_for :exercises, allow_destroy: true
  accepts_nested_attributes_for :segments, allow_destroy: true

  validates :name, :metric, presence: true

  def self.search_by_name(name)
    return all unless name

    query = name.split(' ').reduce(nil) do |q, word|
      q.nil? ? arel_table[:name].matches("%#{word}%") : q.and(arel_table[:name].matches("%#{word}%"))
    end
    where(query)
  end

  def rounds_for_time?
    rounds.present? && time.blank? && interval.blank?
  end

  def amrap?
    time.present? && rounds.blank? && interval.blank?
  end

  def emom?
    time.present? && rounds.present? && (time % rounds).zero?
  end

  def timed_rounds?
    rounds.present? && time.present? && interval.nil?
  end

  def interval?
    interval&.present?
  end

  def logged?(user)
    logs.where(user: user)
  end

  def reps_from_interval
    return nil unless interval?

    interval.split('-').sum(&:to_i)
  end

  # Time cap that formats the seconds DB value to "Minutes:Seconds"
  def time_cap
    return nil if time_cap_seconds.nil?

    duration = ActiveSupport::Duration.build(time_cap_seconds).parts
    format '%<minutes>02d:%<seconds>02d', minutes: duration[:minutes], seconds: duration[:seconds]
  end

  # Time cap is a string in the format "Minutes:Seconds"
  def time_cap=(time_cap)
    if time_cap.include? ':'
      minutes, seconds = time_cap.split(':', 2)
      time_in_seconds = (minutes.to_i.minute + seconds.to_i.second).second
      self.time_cap_seconds = time_in_seconds
    else
      self.time_cap_seconds = time_cap
    end
  end
end
