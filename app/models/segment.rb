class Segment < ApplicationRecord
  belongs_to :workout
  has_one :metric, as: :measurable, dependent: :destroy
  has_many :exercises, dependent: :destroy

  accepts_nested_attributes_for :exercises, allow_destroy: true

  default_scope { order(:id).includes(:exercises) }

  def rounds?
    rounds.present? && time.blank? && interval.blank?
  end

  def amrap?
    time.present? && rounds.blank? && interval.blank?
  end

  def reps_from_interval
    return nil unless interval?

    interval.split('-').sum(&:to_i)
  end
end
