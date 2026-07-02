class Movement < ApplicationRecord
  # Single vs. double loading only applies to handheld implements. Keep the
  # name fallback until seeded taxonomy is complete for all movement records.
  IMPLEMENT_COUNT_NAME_PATTERN = /dumbbell|kettlebell/i

  FAMILIES = {
    monostructural: 0,
    gymnastics: 1,
    weightlifting: 2,
    rest: 3
  }.freeze

  FUNCTIONS = {
    squat: 0,
    hinge: 1,
    vertical_push: 2,
    vertical_pull: 3,
    horizontal_push: 4,
    horizontal_pull: 5,
    trunk_flexion: 6,
    trunk_extension: 7
  }.freeze

  EQUIPMENT = {
    barbell: 0,
    dumbbell: 1,
    kettlebell: 2,
    medicine_ball: 3,
    box: 4,
    pull_up_bar: 5,
    rings: 6,
    rope: 7,
    machine: 8,
    jump_rope: 9,
    sled: 10,
    mixed: 11
  }.freeze

  SKILL_LEVELS = {
    basic: 0,
    intermediate: 1,
    advanced: 2
  }.freeze

  FUNCTION_ROLES = {
    primary: 0,
    secondary: 1,
    tertiary: 2
  }.freeze

  include MovementFunctionRoles

  has_many :exercises, dependent: :destroy
  has_many :movement_logs, dependent: :destroy
  has_many :movement_substitutions, dependent: :destroy
  has_many :substitutes, through: :movement_substitutions, source: :substitute_movement
  has_many :inverse_movement_substitutions,
           class_name: 'MovementSubstitution',
           foreign_key: :substitute_movement_id,
           dependent: :destroy,
           inverse_of: :substitute_movement
  has_many :substituted_for_movements, through: :inverse_movement_substitutions, source: :movement

  enum :family, FAMILIES, prefix: true
  enum :equipment, EQUIPMENT, prefix: true
  enum :skill_level, SKILL_LEVELS, prefix: true

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :supporting_implement_count, -> { where('name ~* ?', IMPLEMENT_COUNT_NAME_PATTERN.source) }

  def supports_implement_count?
    equipment_dumbbell? || equipment_kettlebell? || name.to_s.match?(IMPLEMENT_COUNT_NAME_PATTERN)
  end

  def self.search_by_name(name)
    return all unless name

    query = name.split.reduce(nil) do |q, word|
      q.nil? ? arel_table[:name].matches("%#{word}%") : q.and(arel_table[:name].matches("%#{word}%"))
    end
    where(query)
  end
end
