module WorkoutExtraction
  # Maps the extractor's JSON (see IntendedStimulusPrompt) onto the workout and exercise
  # stimulus columns, dropping anything the columns can't hold: unknown enum labels,
  # non-positive numbers, and percents outside 1..100.
  module IntendedStimulusFields
    GOALS = IntendedStimulus::GOALS.keys.map(&:to_s).freeze
    EFFORTS = IntendedStimulus::EFFORTS.keys.map(&:to_s).freeze
    LOADINGS = IntendedStimulus::LOADINGS.keys.map(&:to_s).freeze
    PERCENT = (1..100)

    # JSON key prefix => [low column, high column]
    PAIRS = {
      round_seconds: %i[stimulus_round_seconds_low stimulus_round_seconds_high],
      percent_1rm: %i[stimulus_percent_1rm_low stimulus_percent_1rm_high],
      working_sets: %i[stimulus_working_sets_low stimulus_working_sets_high],
      rest_seconds: %i[stimulus_rest_seconds_low stimulus_rest_seconds_high]
    }.freeze

    module_function

    # Every workout-level stimulus column, nil where the extraction gave nothing usable, so a
    # forced re-extraction replaces stale values rather than mixing old and new.
    def workout_attrs(data, workout)
      attrs = range_attrs(data, workout)
      PAIRS.each do |key, (low_column, high_column)|
        low, high = ordered_pair(data[:"#{key}_low"], data[:"#{key}_high"], percent: key == :percent_1rm)
        attrs[low_column] = low
        attrs[high_column] = high
      end
      attrs[:stimulus_interval_work_seconds] = positive_int(data[:interval_work_seconds])
      attrs[:stimulus_interval_rest_seconds_min] = positive_int(data[:interval_rest_seconds_min])
      attrs[:stimulus_goal] = label(data[:goal], GOALS)
      attrs
    end

    def movement_attrs(entry)
      {
        stimulus_loading: label(entry[:loading], LOADINGS),
        stimulus_sets_max: positive_int(entry[:sets_max]),
        stimulus_duration_max: positive_int(entry[:duration_max_seconds]),
        stimulus_rest_max_seconds: positive_int(entry[:rest_max_seconds]),
        stimulus_effort: label(entry[:effort], EFFORTS)
      }.compact
    end

    # A lone range value is a ceiling; a weight-scored range is a percent of 1RM.
    def range_attrs(data, workout)
      bounds = [data[:range_low], data[:range_high]].filter_map { |value| positive_int(value) }
      bounds = bounds.select { |value| PERCENT.cover?(value) } if workout.score_weight?
      bounds.sort!
      low, high = bounds.one? ? [nil, bounds.first] : [bounds.first, bounds.last]
      { stimulus_range_low: low, stimulus_range_high: high }
    end

    # Keeps each bound where the model put it, swapping an inverted pair.
    def ordered_pair(low, high, percent: false)
      low, high = [low, high].map { |value| percent ? percent_int(value) : positive_int(value) }
      return [low, high] unless low && high

      [low, high].minmax
    end

    def percent_int(value)
      integer = positive_int(value)
      integer if integer && PERCENT.cover?(integer)
    end

    def positive_int(value)
      integer = Integer(value, exception: false)
      integer if integer&.positive?
    end

    def label(value, allowed)
      value.to_s if allowed.include?(value.to_s)
    end
  end
end
