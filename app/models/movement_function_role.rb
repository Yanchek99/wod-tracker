class MovementFunctionRole < ApplicationRecord
  belongs_to :movement

  enum :movement_function, Movement::FUNCTIONS, prefix: :function
  enum :role, Movement::FUNCTION_ROLES, prefix: true

  validates :movement_function, presence: true, uniqueness: { scope: :movement_id }
  validates :role, presence: true
end
