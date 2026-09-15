# A rule-based (`derived`) or model-generated (`predicted`) intended-stimulus value
# for one workout or one exercise -- never both (a check constraint enforces it).
# Append-only: predictions are kept as history and `current` marks the row to use
# when the target has no authored or extracted value of its own.
class StimulusPrediction < ApplicationRecord
  belongs_to :workout, optional: true
  belongs_to :exercise, optional: true

  enum :source, { derived: 0, predicted: 1 }, prefix: :source
  enum :stimulus_loading, IntendedStimulus::LOADINGS, prefix: :stimulus_loading

  scope :current, -> { where(current: true) }

  validates :model_version, presence: true
  validates :confidence,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }, allow_nil: true
  validates :stimulus_range_low, :stimulus_range_high, :stimulus_sets_max, :stimulus_duration_max,
            numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :exactly_one_target

  private

  def exactly_one_target
    return if workout_id.present? ^ exercise_id.present?

    errors.add(:base, 'must reference exactly one of workout or exercise')
  end
end
