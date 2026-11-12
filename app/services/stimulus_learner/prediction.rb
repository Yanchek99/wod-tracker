module StimulusLearner
  # One target's predicted values, accumulated field by field, with the provenance the writer
  # needs: `predicted` with the lowest contributing confidence once any field is learned,
  # otherwise `derived` (the bodyweight rule) with no confidence.
  class Prediction
    attr_reader :values

    def initialize
      @values = {}
      @confidences = []
    end

    def learned(values, confidence)
      return if values.empty?

      @values.merge!(values)
      @confidences << confidence
    end

    def ruled(values)
      @values.merge!(values)
    end

    def source = @confidences.any? ? :predicted : :derived

    def model_version = @confidences.any? ? MODEL_VERSION : RULES_VERSION

    def confidence = @confidences.min
  end
end
