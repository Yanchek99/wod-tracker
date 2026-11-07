# One performance point for an athlete on a movement: what they can do (max load, unbroken reps),
# how long a piece of work took them (timed), or that they cannot do the movement at all.
# Columns mirror `movement_logs`; `kind` says which of them carry the result and which are the
# setting (see the design on issue #1980). Rows are written by estimators (`source`) and read by
# the scaling engine.
class AthleteCapability < ApplicationRecord
  KINDS = { max_effort: 0, unbroken: 1, cannot_do: 2, timed: 3 }.freeze
  MEASUREMENTS = %i[load reps distance duration_seconds].freeze

  # Which measurement columns each kind requires, forbids, or needs one of.
  MEASUREMENT_RULES = {
    max_effort: { forbidden: %i[reps duration_seconds], exactly_one_of: %i[load distance] },
    unbroken: { required: %i[reps], forbidden: %i[duration_seconds] },
    timed: { required: %i[duration_seconds], at_least_one_of: %i[reps distance] },
    cannot_do: { forbidden: MEASUREMENTS }
  }.freeze

  belongs_to :user
  belongs_to :movement

  enum :kind, KINDS, prefix: :kind
  enum :source, { heuristic: 0, learned: 1 }, prefix: :source
  enum :distance_unit, { meter: 0, foot: 1, inch: 2 }, prefix: :distance_unit

  scope :for, ->(user, movement) { where(user:, movement:) }

  validates :kind, :source, :model_version, :computed_at, presence: true
  validates(*MEASUREMENTS, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true)
  validates :confidence, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }, allow_nil: true
  validates :sample_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :distance_and_unit_given_together
  validate :measurements_match_kind

  private

  def distance_and_unit_given_together
    return if distance.present? == distance_unit.present?

    errors.add(distance.present? ? :distance_unit : :distance, :blank)
  end

  def measurements_match_kind
    rule = MEASUREMENT_RULES[kind&.to_sym]
    return unless rule

    Array(rule[:required]).each { |column| errors.add(column, :blank) if self[column].blank? }
    Array(rule[:forbidden]).each { |column| errors.add(column, :present) if self[column].present? }
    check_one_of(rule)
  end

  def check_one_of(rule)
    { exactly_one_of: ->(count) { count == 1 }, at_least_one_of: ->(count) { count >= 1 } }.each do |key, ok|
      columns = rule[key]
      next if columns.nil? || ok.call(columns.count { |column| self[column].present? })

      errors.add(:base, "must have #{columns.join(' or ')} set as the kind requires")
    end
  end
end
