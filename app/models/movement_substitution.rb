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
  validates :substitute_movement_id, uniqueness: { scope: %i[movement_id direction] }
  validate :substitute_is_different_movement

  private

  def substitute_is_different_movement
    return if movement_id.blank? || substitute_movement_id.blank?

    errors.add(:substitute_movement, 'must be different from movement') if movement_id == substitute_movement_id
  end
end
