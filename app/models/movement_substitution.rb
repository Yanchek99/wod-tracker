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
  validate :inverse_pair_is_absent

  private

  def substitute_is_different_movement
    return if movement_id.blank? || substitute_movement_id.blank?

    errors.add(:substitute_movement, 'must be different from movement') if movement_id == substitute_movement_id
  end

  def inverse_pair_is_absent
    return if movement_id.blank? || substitute_movement_id.blank?

    errors.add(:substitute_movement, 'already has an inverse substitution') if inverse_substitution?
  end

  def inverse_substitution?
    inverse_substitution_scope.exists?
  end

  def inverse_substitution_scope
    # One directed row owns each movement pair. Reverse rows are either redundant
    # for lateral substitutions or contradictory for easier/harder substitutions.
    scope = self.class.where(
      movement_id: substitute_movement_id,
      substitute_movement_id: movement_id
    )
    persisted? ? scope.where.not(id:) : scope
  end
end
