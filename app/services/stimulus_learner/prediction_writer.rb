module StimulusLearner
  # Persists one target's predicted stimulus values as its single `current` prediction row.
  # Append-only: a change inserts a new row and retires the previous current one in the same
  # transaction; an identical rerun (same values, source and model version) writes nothing.
  # Prediction values never touch the target's own authored/extracted stimulus columns.
  module PredictionWriter
    module_function

    # target: a Workout or Exercise. values: stimulus field => value, nils already removed.
    def write(target, values:, source:, model_version:, confidence:)
      outcome = outcome(target, values:, source:, model_version:)
      return outcome unless outcome == :created

      current = target.stimulus_predictions.current.first
      StimulusPrediction.transaction do
        current&.update!(current: false)
        target.stimulus_predictions.create!(**values, source:, model_version:, confidence:, current: true)
      end
      :created
    end

    # What write would do, without writing: :skipped, :unchanged or :created.
    def outcome(target, values:, source:, model_version:)
      return :skipped if values.empty?
      return :unchanged if same?(target.stimulus_predictions.current.first, values, source, model_version)

      :created
    end

    def same?(current, values, source, model_version)
      return false unless current
      return false unless current.source == source.to_s && current.model_version == model_version

      fields = target_fields(current)
      fields.all? { |field| current[field] == normalized(values[field.to_sym]) }
    end

    def target_fields(prediction)
      prediction.workout_id ? Workout::STIMULUS_FIELDS : Exercise::STIMULUS_FIELDS
    end

    # Enum values come back as strings from the row; compare like for like.
    def normalized(value)
      value.is_a?(Symbol) ? value.to_s : value
    end
  end
end
