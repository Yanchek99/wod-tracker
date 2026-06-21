class MovementLog < ApplicationRecord
  include MovementLogPerformance

  belongs_to :log
  belongs_to :movement

  scope :for_movement, ->(movement) { where(movement:) }
  scope :for_movement_family, lambda { |movement_or_family|
    family = movement_or_family.respond_to?(:family) ? movement_or_family.family : movement_or_family
    return none if family.blank?

    joins(:movement).where(movements: { family: })
  }
end
