class MovementLog < ApplicationRecord
  include MovementLogPerformance

  belongs_to :log
  belongs_to :movement

  scope :for_movement, ->(movement) { where(movement:) }
  scope :for_movement_family, lambda { |family|
    family = family.family if family.is_a?(Movement)
    return none if family.blank?

    joins(:movement).where(movements: { family: })
  }
  scope :for_similar_movement, lambda { |movement|
    family = movement.family
    return none if family.blank?

    query = joins(:movement).where(movements: { family:, equipment: movement.equipment })
    primary_functions = movement.movement_function_roles.role_primary.pluck(:movement_function)
    return query if primary_functions.empty?

    query
      .joins(movement: :movement_function_roles)
      .where(movement_function_roles: { movement_function: primary_functions, role: Movement.role_value(:primary) })
      .distinct
  }
end
