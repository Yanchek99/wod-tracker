module IntendedStimulusHelper
  # The workout's expected-result range rendered in its own score unit: MM:SS for a
  # time-scored workout, a percent of 1RM for a weight-scored one, "N reps"/"N rounds"
  # otherwise. Falls back to the current prediction when the workout has no range of its own.
  # nil when neither has one.
  def intended_stimulus_range(workout)
    low, high, = stimulus_pair(workout, :stimulus_range_low, :stimulus_range_high)
    return if low.blank? && high.blank?

    "#{stimulus_bounds_text(low, high) { |value| stimulus_value_text(workout, value) }}#{stimulus_range_unit(workout)}"
  end

  # A derived or predicted value, as opposed to CrossFit's (extracted) or a coach's (authored).
  def stimulus_calculated?(stimulus_value)
    %w[derived predicted].include?(stimulus_value&.source.to_s)
  end

  # [low, high, calculated] for one low/high pair. The workout's own pair wins whole; only when
  # it has neither bound does the pair come from the current prediction, so the two bounds
  # never mix sources.
  def stimulus_pair(record, low_field, high_field)
    own = [record[low_field], record[high_field]]
    return [*own, false] if own.any?

    low = record.intended_stimulus_for(low_field)
    high = record.intended_stimulus_for(high_field)
    [low&.value, high&.value, stimulus_calculated?(low || high)]
  end

  private

  # "low–high", "≤ high", "≥ low", or one value when they're equal.
  def stimulus_bounds_text(low, high)
    return "≤ #{yield high}" if low.blank?
    return "≥ #{yield low}" if high.blank?
    return yield(low) if high == low

    "#{yield low}–#{yield high}"
  end

  def stimulus_value_text(workout, value)
    workout.score_measurement == 'time' ? clock_duration(value) : value.to_s
  end

  def stimulus_range_unit(workout)
    case workout.score_measurement
    when 'time' then ''
    when 'weight' then '%'
    else " #{workout.score_measurement.pluralize}"
    end
  end
end
