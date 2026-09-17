module IntendedStimulusHelper
  # The workout's expected-result range rendered in its own score unit: MM:SS for a
  # time-scored workout, "N reps"/"N rounds" otherwise. nil when no range is set.
  def intended_stimulus_range(workout)
    low = workout.stimulus_range_low
    high = workout.stimulus_range_high
    return if low.blank? && high.blank?

    "#{stimulus_bounds_text(workout, low, high)}#{stimulus_range_unit(workout)}"
  end

  private

  def stimulus_bounds_text(workout, low, high)
    return "≤ #{stimulus_value_text(workout, high)}" if low.blank?
    return stimulus_value_text(workout, low) if high.blank? || high == low

    "#{stimulus_value_text(workout, low)}–#{stimulus_value_text(workout, high)}"
  end

  def stimulus_value_text(workout, value)
    workout.score_measurement == 'time' ? clock_duration(value) : value.to_s
  end

  def stimulus_range_unit(workout)
    workout.score_measurement == 'time' ? '' : " #{workout.score_measurement.pluralize}"
  end
end
