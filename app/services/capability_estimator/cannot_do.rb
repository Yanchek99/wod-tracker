class CapabilityEstimator
  # Conservative "this athlete cannot do the movement" marks (a false positive hurts more than a
  # miss). Needs MIN_TOTAL_LOGS logs overall, then either of:
  #  (a) an easier substitute logged in place of the prescribed movement in >= MIN_SUBSTITUTION_LOGS
  #      logs, with no later successful log of the prescribed movement; or
  #  (b) every logged attempt of the movement was verifiably singles (<= TINY_SET) despite >= 5 reps.
  # Reps with no captured set_breakdown are unverifiable (nil), so they never count as tiny sets, but
  # any later log of the movement with reps counts as a success (unverifiable is not failure).
  module CannotDo
    MIN_VOLUME_REPS = 5

    def self.call(samples)
      return [] if samples.total_logs < MIN_TOTAL_LOGS

      rows = substituted(samples) + singles(samples)
      rows.uniq { |row| row[:movement_id] }
    end

    def self.substituted(samples)
      substitution_logs(samples).filter_map do |movement_id, logs|
        next if logs.size < MIN_SUBSTITUTION_LOGS
        next if succeeded_since?(samples, movement_id, logs.map(&:created_at).min)

        row(movement_id, logs.size)
      end
    end

    def self.singles(samples)
      breakable = samples.movement_logs.select { |movement_log| movement_log.movement.breakable }
      breakable.group_by(&:movement_id).filter_map do |movement_id, movement_logs|
        row(movement_id, movement_logs.size) if movement_logs.all? { |movement_log| tiny_set?(movement_log) }
      end
    end

    # Singles only count against the athlete when the workout asked for bigger sets: an EMOM of one
    # muscle-up per minute is logged as singles by everyone. An unknown structure is not evidence.
    def self.tiny_set?(movement_log)
      verified = movement_log.verified_unbroken_reps
      return false unless !verified.nil? && verified <= TINY_SET && movement_log.reps.to_i >= MIN_VOLUME_REPS

      round_sizes = movement_log.log.round_sizes_for_set_breakdown(movement_log)
      round_sizes.present? && round_sizes.all? { |size| size > TINY_SET }
    end

    def self.succeeded_since?(samples, movement_id, since)
      samples.movement_logs.any? do |movement_log|
        movement_log.movement_id == movement_id && movement_log.log.created_at > since &&
          movement_log.reps.to_i.positive?
      end
    end

    # { prescribed movement id => logs where an easier substitute was logged instead }
    def self.substitution_logs(samples)
      events = substitution_events(samples, easier_pairs)
      events.uniq.group_by(&:first).transform_values { |pairs| pairs.map(&:last) }
    end

    # [prescribed movement id, log] for each exercise the athlete swapped for an easier movement.
    def self.substitution_events(samples, easier)
      exercises = Hash.new { |cache, workout| cache[workout] = workout.exercises_for_log_recording.to_a }
      samples.movement_logs.group_by(&:log).flat_map do |log, movement_logs|
        exercises[log.workout].zip(movement_logs).filter_map do |exercise, movement_log|
          [exercise.movement_id, log] if movement_log && easier.include?([exercise.movement_id, movement_log.movement_id])
        end
      end
    end

    # [prescribed movement id, easier movement id] pairs, whichever way the substitution row is stored.
    def self.easier_pairs
      MovementSubstitution.direction_easier.pluck(:movement_id, :substitute_movement_id) +
        MovementSubstitution.direction_harder.pluck(:substitute_movement_id, :movement_id)
    end

    def self.row(movement_id, sample_count)
      { movement_id:, kind: :cannot_do, sample_count: }
    end
  end
end
