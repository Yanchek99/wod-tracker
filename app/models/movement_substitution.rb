class MovementSubstitution < ApplicationRecord
  DIRECTIONS = {
    easier: 0,
    harder: 1,
    lateral: 2
  }.freeze

  belongs_to :movement
  belongs_to :substitute_movement, class_name: 'Movement'

  enum :direction, DIRECTIONS, prefix: true

  validates :direction, presence: true
  validates :substitute_movement_id, uniqueness: { scope: :movement_id }
  validate :substitute_is_different_movement
  validate :inverse_direction_is_consistent

  private

  def substitute_is_different_movement
    return if movement_id.blank? || substitute_movement_id.blank?

    errors.add(:substitute_movement, 'must be different from movement') if movement_id == substitute_movement_id
  end

  def inverse_direction_is_consistent
    return if movement_id.blank? || substitute_movement_id.blank? || direction.blank?

    errors.add(:direction, 'contradicts inverse substitution') if contradictory_inverse_substitution?
  end

  def contradictory_inverse_substitution?
    inverse_substitution_scope.exists?
  end

  def inverse_substitution_scope
    # Reverse lateral rows are semantically redundant, and reverse easier/harder rows are
    # contradictory, so a single directed row owns each movement pair.
    scope = self.class.where(
      movement_id: substitute_movement_id,
      substitute_movement_id: movement_id,
      direction: self.class.directions.fetch(direction)
    )
    persisted? ? scope.where.not(id:) : scope
  end
end
