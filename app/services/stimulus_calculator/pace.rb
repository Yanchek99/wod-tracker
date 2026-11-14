module StimulusCalculator
  # Seconds for a volume of one movement at its load class (Loading), from the movement's bucket
  # in the reference table; nil when no bucket fits or a needed pace is missing (callers then
  # leave the value blank). A box, rope or wall-ball target above its typical height makes each
  # rep slower, and a lower one faster.
  module Pace
    module_function

    def seconds(exercise, volume, reference)
      profile = reference.profile(exercise.movement)
      return if profile.nil? || volume.empty?

      loading = Loading.call(exercise, reference)
      parts = volume.map { |unit, amount| profile.seconds_per(unit, loading)&.*(amount) }
      parts.sum * height_factor(exercise, profile, reference) if parts.none?(&:nil?)
    end

    # Prescribed height / typical height, within the table's bounds; 1 without both. A height
    # is only a target beside real reps (Volume).
    def height_factor(exercise, profile, reference)
      return 1 unless profile.typical_height && exercise.reps.to_i > 1

      height = StimulusReference.inches(exercise.male_distance || exercise.distance, exercise.distance_unit)
      return 1 unless height&.positive?

      (height / profile.typical_height).clamp(*reference.constant(:height_factor_range))
    end
  end
end
