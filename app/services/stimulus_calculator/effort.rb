module StimulusCalculator
  # Per-movement guidance from one effort of that movement (one set or round): a sets guide
  # (reps per set over the load class's expected unbroken chunk), a time ceiling (the effort at
  # slow pace), and an effort label from the effort's fast duration.
  module Effort
    LOADED = %w[light moderate heavy].freeze

    module_function

    def call(exercise, loading, reference)
      fast = Pace.seconds(exercise, Volume.per_effort(exercise), reference)
      {
        stimulus_sets_max: sets_max(exercise, loading, reference),
        stimulus_duration_max: fast && (fast * reference.constant(:slow_factor)).round,
        stimulus_effort: fast && !weight_scored?(exercise) ? label(fast, reference) : nil
      }
    end

    def sets_max(exercise, loading, reference)
      reps = Volume.reps_per_set(exercise)
      return unless LOADED.include?(loading) && reps.positive?

      (reps.to_f / reference.constant(:chunk_reps).fetch(loading)).ceil
    end

    def label(seconds, reference)
      cutoffs = reference.constant(:effort_seconds)
      %w[sprint hard threshold].find { |effort| seconds < cutoffs.fetch(effort) } || 'steady'
    end

    def weight_scored?(exercise)
      exercise.segment.workout.score_weight?
    end
  end
end
