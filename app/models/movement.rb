class Movement < ApplicationRecord
  # Single vs. double loading only applies to handheld implements. Detected by name for now;
  # swap this for the equipment taxonomy (#1629) once it lands.
  IMPLEMENT_COUNT_NAME_PATTERN = /dumbbell|kettlebell/i

  has_many :exercises, dependent: :destroy
  has_many :movement_logs, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :supporting_implement_count, -> { where('name ~* ?', IMPLEMENT_COUNT_NAME_PATTERN.source) }

  def supports_implement_count?
    name.to_s.match?(IMPLEMENT_COUNT_NAME_PATTERN)
  end

  def self.search_by_name(name)
    return all unless name

    query = name.split.reduce(nil) do |q, word|
      q.nil? ? arel_table[:name].matches("%#{word}%") : q.and(arel_table[:name].matches("%#{word}%"))
    end
    where(query)
  end
end
