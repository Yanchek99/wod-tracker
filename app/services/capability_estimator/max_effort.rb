class CapabilityEstimator
  # Estimated one-rep max (Epley) per loaded movement. Metcon-derived estimates are only a floor, so
  # confidence is lower unless a log came from a max-effort style workout.
  module MaxEffort
    CONFIDENCE = { floor_only: 0.4, max_effort_source: 0.7, sample_bonus: 0.1, sample_bonus_at: 3, cap: 0.9 }.freeze

    def self.call(samples)
      samples.movement_logs.group_by { |movement_log| [movement_log.movement_id, Setting.implement_count(movement_log)] }
             .filter_map do |(movement_id, implement_count), movement_logs|
        estimates = movement_logs.filter_map { |movement_log| estimate(movement_log) }
        next if estimates.empty?

        row(movement_id, implement_count, estimates)
      end
    end

    def self.estimate(movement_log)
      reps = movement_log.verified_unbroken_reps
      return unless movement_log.load.to_i.positive? && reps.to_i.positive?

      value = reps == 1 ? movement_log.load : movement_log.load * (1 + ([reps, EPLEY_REP_CAP].min / 30.0))
      [value, max_effort_source?(movement_log)]
    end

    def self.max_effort_source?(movement_log)
      workout = movement_log.log.workout
      workout.set_based_lifting? || workout.single_achievement_test?
    end

    def self.row(movement_id, implement_count, estimates)
      { movement_id:, implement_count:, kind: :max_effort, load: estimates.map(&:first).max.round, sample_count: estimates.size,
        confidence: confidence(estimates) }
    end

    def self.confidence(estimates)
      base = estimates.any?(&:last) ? CONFIDENCE[:max_effort_source] : CONFIDENCE[:floor_only]
      bonus = estimates.size >= CONFIDENCE[:sample_bonus_at] ? CONFIDENCE[:sample_bonus] : 0
      [base + bonus, CONFIDENCE[:cap]].min
    end
  end
end
