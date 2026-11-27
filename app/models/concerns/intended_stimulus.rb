# Shared resolution of a record's intended-stimulus attributes. Included by the
# targets that carry authored/extracted stimulus columns (Workout, Exercise).
# Each includer defines STIMULUS_FIELDS listing its own stimulus value columns.
#
# The structured columns hold the value a coach authored or an importer extracted
# from the "Stimulus and Strategy" prose. Rule-based and model-generated values
# never touch them -- they live in stimulus_predictions. See cf/docs/decisions.md.
module IntendedStimulus
  extend ActiveSupport::Concern

  # Loading intent, per the Programming Basics consecutive-reps lens.
  LOADINGS = { unloaded: 0, light: 1, moderate: 2, heavy: 3 }.freeze

  # Where a structured value on the row itself came from.
  SOURCES = { authored: 0, extracted: 1 }.freeze

  # What the workout is for. The three heavy-day goals are the L2 guide's three ways to
  # approach working sets: add load each set, hold a percentage, or find a new max.
  GOALS = {
    for_time: 0, amrap: 1, intervals: 2,
    heavy_ascending: 3, heavy_hold_percent: 4, heavy_find_max: 5,
    skill_practice: 6
  }.freeze

  # How hard a single movement's effort should be.
  EFFORTS = { sprint: 0, hard: 1, threshold: 2, steady: 3 }.freeze

  # Low/high column pairs where the high end may not fall below the low end.
  RANGE_PAIRS = [
    %w[stimulus_range_low stimulus_range_high],
    %w[stimulus_round_seconds_low stimulus_round_seconds_high],
    %w[stimulus_percent_1rm_low stimulus_percent_1rm_high],
    %w[stimulus_working_sets_low stimulus_working_sets_high],
    %w[stimulus_rest_seconds_low stimulus_rest_seconds_high]
  ].freeze

  # Positive-integer workout-level columns (the range has its own rule, see Workout).
  WORKOUT_POSITIVE_FIELDS = %w[
    stimulus_round_seconds_low stimulus_round_seconds_high
    stimulus_working_sets_low stimulus_working_sets_high
    stimulus_rest_seconds_low stimulus_rest_seconds_high
    stimulus_interval_work_seconds stimulus_interval_rest_seconds_min
  ].freeze

  PERCENT_FIELDS = %w[stimulus_percent_1rm_low stimulus_percent_1rm_high].freeze

  # One resolved stimulus attribute: its value plus where the value came from.
  # confidence is nil for an authored/extracted value and set for a prediction.
  StimulusValue = Data.define(:value, :source, :confidence)

  included do
    has_many :stimulus_predictions, dependent: :destroy
    enum :stimulus_source, SOURCES, prefix: :stimulus_source
    include RangeOrdering
  end

  # Resolves one stimulus column to its value and provenance: an authored or
  # extracted column wins; otherwise the current prediction row; otherwise nil.
  def intended_stimulus_for(field)
    name = field.to_s
    raise ArgumentError, "#{self.class} has no stimulus field #{name.inspect}" unless self.class::STIMULUS_FIELDS.include?(name)

    authored = self[name]
    return StimulusValue.new(value: authored, source: stimulus_source, confidence: nil) unless authored.nil?

    prediction = stimulus_predictions.current.first
    return if prediction.nil?

    StimulusValue.new(value: prediction[name], source: prediction.source, confidence: prediction.confidence)
  end
end
