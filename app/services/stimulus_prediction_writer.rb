# Persists one target's predicted stimulus values as its single `current` prediction row.
# Append-only: a change inserts a new row and retires the previous current one in the same
# transaction; an identical rerun (same values, source and model version) writes nothing; no
# values at all retire the current row, so a value nothing supports any more stops showing.
# Prediction values never touch the target's own authored/extracted stimulus columns.
#
# `prediction` is anything with values (stimulus field => value, nils removed), source,
# model_version and confidence -- for example a Row.
module StimulusPredictionWriter
  Row = Data.define(:values, :source, :model_version, :confidence)

  module_function

  # target: a Workout or Exercise.
  def write(target, prediction)
    outcome = outcome(target, prediction)
    current = target.stimulus_predictions.current.first
    current.update!(current: false) if outcome == :retired
    return outcome unless outcome == :created

    StimulusPrediction.transaction do
      current&.update!(current: false)
      target.stimulus_predictions.create!(**prediction.values, source: prediction.source,
                                                               model_version: prediction.model_version,
                                                               confidence: prediction.confidence, current: true)
    end
    :created
  end

  # What write would do, without writing: :skipped, :retired, :unchanged or :created.
  def outcome(target, prediction)
    current = target.stimulus_predictions.current.first
    return current ? :retired : :skipped if prediction.values.empty?
    return :unchanged if same?(current, prediction)

    :created
  end

  def same?(current, prediction)
    return false unless current
    return false unless current.source == prediction.source.to_s && current.model_version == prediction.model_version

    target_fields(current).all? { |field| current[field] == normalized(prediction.values[field.to_sym]) }
  end

  def target_fields(prediction)
    prediction.workout_id ? Workout::STIMULUS_FIELDS : Exercise::STIMULUS_FIELDS
  end

  # Enum values come back as strings from the row; compare like for like.
  def normalized(value)
    value.is_a?(Symbol) ? value.to_s : value
  end
end
