class CapabilityEstimator
  # The most reps the athlete verifiably did without stopping, one row per setting (load, or
  # distance and unit). Skips movements that cannot be broken into sets.
  module Unbroken
    def self.call(samples)
      eligible = samples.movement_logs.select { |movement_log| movement_log.movement.breakable }
      eligible.group_by { |movement_log| setting(movement_log) }.filter_map do |setting, movement_logs|
        reps = movement_logs.filter_map(&:verified_unbroken_reps).select(&:positive?).max
        next unless reps

        { kind: :unbroken, reps:, sample_count: movement_logs.size, **setting }
      end
    end

    def self.setting(movement_log)
      { movement_id: movement_log.movement_id, load: movement_log.load,
        distance: movement_log.distance, distance_unit: movement_log.distance_unit }
    end
  end
end
