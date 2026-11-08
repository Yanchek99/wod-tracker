class CapabilityEstimator
  # How long a piece of work took, one row per setting (reps, distance and unit, load) keeping the
  # fastest result. Data is sparse: only movement logs where the athlete entered a duration count.
  module Timed
    CONFIDENCE = { base: 0.5, per_extra_log: 0.1, cap: 0.8 }.freeze

    def self.call(samples)
      eligible = samples.movement_logs.select { |movement_log| timed?(movement_log, samples) }
      eligible.group_by { |movement_log| setting(movement_log) }.map do |setting, movement_logs|
        { kind: :timed, duration_seconds: movement_logs.map(&:duration_seconds).min,
          sample_count: movement_logs.size, confidence: confidence(movement_logs.size), **setting }
      end
    end

    # A prescribed duration is copied onto the movement log when the log form is built, so a duration
    # equal to the exercise's own prescribed time is the prescription, not something the athlete entered.
    def self.timed?(movement_log, samples)
      movement_log.duration_seconds.to_i.positive? && !prescribed_duration?(movement_log, samples) &&
        (movement_log.reps.to_i.positive? || Setting.valid_distance?(movement_log))
    end

    def self.prescribed_duration?(movement_log, samples)
      exercise = samples.exercise_for(movement_log)
      return false unless exercise

      exercise.prescription_metrics.any? do |metric|
        %w[seconds time].include?(metric.measurement) && metric.value == movement_log.duration_seconds
      end
    end

    def self.setting(movement_log)
      { movement_id: movement_log.movement_id, reps: Setting.positive(movement_log.reps), **Setting.for(movement_log) }
    end

    def self.confidence(count)
      [CONFIDENCE[:base] + (CONFIDENCE[:per_extra_log] * (count - 1)), CONFIDENCE[:cap]].min
    end
  end
end
