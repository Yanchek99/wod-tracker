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

  PATTERNS = {
    squat: 0,
    hinge: 1,
    vertical_push: 2,
    vertical_pull: 3,
    carry: 4,
    trunk_flexion: 5,
    locomotion: 6,
    inversion: 7,
    jump: 8,
    rest: 9,
    horizontal_push: 10,
    horizontal_pull: 11,
    trunk_extension: 12,
    trunk_rotation: 13
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
  scope :with_pattern, ->(pattern) { where('? = ANY(patterns)', PATTERNS.fetch(pattern.to_sym)) }

  PATTERNS.each_key do |pattern_name|
    define_method(:"pattern_#{pattern_name}?") { pattern?(pattern_name) }
  end

  def patterns=(values)
    super(Array(values).filter_map { |value| self.class.pattern_value(value) })
  end

  def pattern?(pattern)
    patterns.include?(self.class.pattern_value(pattern))
  end

  def self.pattern_value(pattern)
    pattern.is_a?(Symbol) || pattern.is_a?(String) ? PATTERNS.fetch(pattern.to_sym) : pattern
  end

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

  def family_movements
    return self.class.none if family.blank?

    # Includes self so family fallback history contains exact movement history too.
    self.class.where(family:)
  end
end
