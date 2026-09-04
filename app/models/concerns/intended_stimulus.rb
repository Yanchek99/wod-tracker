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

  # One resolved stimulus attribute: its value plus where the value came from.
  # confidence is nil for an authored/extracted value and set for a prediction.
  StimulusValue = Data.define(:value, :source, :confidence)

  included do
    has_many :stimulus_predictions, dependent: :destroy
    enum :stimulus_source, SOURCES, prefix: :stimulus_source
    validate :stimulus_range_ordered
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

  private

  # Only a whole-workout target carries a range; a no-op on records without one.
  def stimulus_range_ordered
    return unless respond_to?(:stimulus_range_low) && respond_to?(:stimulus_range_high)
    return if stimulus_range_low.blank? || stimulus_range_high.blank?
    return if stimulus_range_high >= stimulus_range_low

    errors.add(:stimulus_range_high, 'must be at least the low end of the range')
  end
end
