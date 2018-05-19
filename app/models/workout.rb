class Workout < ApplicationRecord
  belongs_to :measurement

  has_many :exercises, dependent: :destroy
  has_many :movements, through: :exercises
  has_many :logs, dependent: :destroy
  has_many :movement_logs, through: :logs

  accepts_nested_attributes_for :exercises, allow_destroy: true

  validates :name, :measurement, presence: true

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
    time.present? && rounds.present? && time.eql?(rounds)
  end

  def timed_rounds?
    rounds.present? && time.present? && interval.nil?
  end

  def logged?(user)
    logs.where(user: user)
  end
end
