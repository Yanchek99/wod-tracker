# One performance point for an athlete on a movement: what they can do (max load, unbroken reps),
# how long a piece of work took them (timed), or that they cannot do the movement at all.
# Columns mirror `movement_logs`; `kind` says which of them carry the result and which are the
# setting (see the design on issue #1980). Rows are written by estimators (`source`) and read by
# the scaling engine.
class AthleteCapability < ApplicationRecord
  KINDS = { max_effort: 0, unbroken: 1, cannot_do: 2, timed: 3 }.freeze

  belongs_to :user
  belongs_to :movement

  enum :kind, KINDS, prefix: :kind
  enum :source, { heuristic: 0, learned: 1 }, prefix: :source
  enum :distance_unit, { meter: 0, foot: 1, inch: 2 }, prefix: :distance_unit

  scope :for, ->(user, movement) { where(user:, movement:) }
end
