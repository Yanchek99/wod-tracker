module StimulusCalculator
  # Seconds for a volume of one movement at its load class, from the reference table; nil when
  # the movement or a needed pace is missing (callers then leave the value blank).
  module Pace
    module_function

    def seconds(exercise, volume, loading, reference)
      entry = reference.movement(exercise.movement.name)
      return if entry.nil? || volume.empty?

      parts = volume.map { |unit, amount| entry.seconds_per(unit, loading)&.*(amount) }
      parts.sum if parts.none?(&:nil?)
    end
  end
end
