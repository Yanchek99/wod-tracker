class CapabilityEstimator
  # The most reps the athlete verifiably did without stopping, one row per setting (load, or
  # distance and unit). Skips movements that cannot be broken into sets.
  module Unbroken
    def self.call(samples)
      eligible = samples.movement_logs.select { |movement_log| eligible?(movement_log) }
      eligible.group_by { |movement_log| setting(movement_log) }.map do |setting, movement_logs|
        { kind: :unbroken, reps: movement_logs.filter_map { |movement_log| reps(movement_log) }.max,
          sample_count: movement_logs.size, **setting }
      end
    end

    # A log backs a point only with a verified positive rep count. A single rep at a distance is the
    # per-round placeholder of a distance movement (Murph's 1600 m run), not an unbroken-reps result.
    def self.eligible?(movement_log)
      reps = reps(movement_log)
      reps.present? && movement_log.movement.breakable &&
        !(reps == 1 && Setting.valid_distance?(movement_log))
    end

    def self.reps(movement_log)
      verified = movement_log.verified_unbroken_reps
      verified if verified.to_i.positive?
    end

    def self.setting(movement_log)
      { movement_id: movement_log.movement_id, **Setting.for(movement_log) }
    end
  end
end
