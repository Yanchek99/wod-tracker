class CapabilityEstimator
  # How long a piece of work took, one row per setting (reps, distance and unit, load) keeping the
  # fastest result. Data is sparse: only movement logs where the athlete entered a duration count.
  module Timed
    CONFIDENCE = { base: 0.5, per_extra_log: 0.1, cap: 0.8 }.freeze

    def self.call(samples)
      eligible = samples.movement_logs.select { |movement_log| timed?(movement_log) }
      eligible.group_by { |movement_log| setting(movement_log) }.map do |setting, movement_logs|
        { kind: :timed, duration_seconds: movement_logs.map(&:duration_seconds).min,
          sample_count: movement_logs.size, confidence: confidence(movement_logs.size), **setting }
      end
    end

    def self.timed?(movement_log)
      movement_log.duration_seconds.to_i.positive? && (movement_log.reps.to_i.positive? || movement_log.distance.to_i.positive?)
    end

    def self.setting(movement_log)
      { movement_id: movement_log.movement_id, reps: movement_log.reps, load: movement_log.load,
        distance: movement_log.distance, distance_unit: movement_log.distance_unit }
    end

    def self.confidence(count)
      [CONFIDENCE[:base] + CONFIDENCE[:per_extra_log] * (count - 1), CONFIDENCE[:cap]].min
    end
  end
end
