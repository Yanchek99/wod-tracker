module IntendedStimulus
  # Validates that each stimulus low/high pair the record carries is ordered. Shared by the
  # IntendedStimulus targets and StimulusPrediction, which holds the same value columns.
  module RangeOrdering
    extend ActiveSupport::Concern

    included do
      validate :stimulus_range_ordered
    end

    private

    # Pairs a record lacks (an exercise has none) are skipped.
    def stimulus_range_ordered
      RANGE_PAIRS.each do |low_field, high_field|
        next unless has_attribute?(low_field) && has_attribute?(high_field)

        low = self[low_field]
        high = self[high_field]
        next if low.blank? || high.blank? || high >= low

        errors.add(high_field, 'must be at least the low end of the range')
      end
    end
  end
end
