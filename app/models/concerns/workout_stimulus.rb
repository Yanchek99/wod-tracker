# A workout's intended-stimulus columns: the goal, the expected-result range, and the round,
# heavy-day and interval targets. Resolution and range ordering come from IntendedStimulus.
module WorkoutStimulus
  extend ActiveSupport::Concern
  include IntendedStimulus

  # Columns intended_stimulus_for can resolve.
  STIMULUS_FIELDS = (
    %w[stimulus_goal stimulus_range_low stimulus_range_high] +
    IntendedStimulus::WORKOUT_POSITIVE_FIELDS + IntendedStimulus::PERCENT_FIELDS
  ).freeze

  included do
    enum :stimulus_goal, IntendedStimulus::GOALS, prefix: :stimulus_goal

    validates :stimulus_range_low, :stimulus_range_high, *IntendedStimulus::WORKOUT_POSITIVE_FIELDS,
              numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
    validates(*IntendedStimulus::PERCENT_FIELDS,
              numericality: { only_integer: true, in: 1..100 }, allow_nil: true)
    # A weight-scored workout's expected result is a percent of the athlete's 1RM, not a load.
    validates :stimulus_range_low, :stimulus_range_high,
              numericality: { in: 1..100 }, allow_nil: true, if: :score_weight?
  end
end
