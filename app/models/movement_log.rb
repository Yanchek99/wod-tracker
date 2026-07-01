class MovementLog < ApplicationRecord
  include MovementLogPerformance

  belongs_to :log
  belongs_to :movement

  scope :for_movement, ->(movement) { where(movement:) }
  scope :for_movement_family, lambda { |movement_or_family|
    unless movement_or_family.is_a?(Movement)
      family = movement_or_family
      return none if family.blank?

      return joins(:movement).where(movements: { family: })
    end

    movement = movement_or_family
    family = movement.family
    return none if family.blank?

    query = joins(:movement).where(movements: { family:, equipment: movement.equipment })
    primary_functions = movement.movement_function_assignments.role_primary.pluck(:movement_function)
    return query if primary_functions.empty?

    query
      .joins(movement: :movement_function_assignments)
      .where(movement_function_assignments: { movement_function: primary_functions, role: Movement.role_value(:primary) })
      .distinct
  }
end
