module StimulusCalculator
  # How heavy a movement should feel. A barbell lift: prescribed load against the reference
  # athlete's 1RM for its lift family -- light below the family's boundary, heavy at or above the
  # heavy boundary (L2: heavy-day working sets at or above 80-85% of 1RM), moderate in between.
  # An implement: prescribed load against its typical Rx load, so the usual 35/53-lb kettlebell
  # is light and a 70-lb one is not. Body weight only (no load, no loaded equipment) is
  # unloaded, per CrossFit's definition.
  module Loading
    LOADED_EQUIPMENT = %w[barbell dumbbell kettlebell medicine_ball sandbag vest plate sled].freeze

    module_function

    def call(exercise, reference)
      return 'unloaded' if unloaded?(exercise)

      profile = reference.profile(exercise.movement)
      ratio = ratio(exercise, profile)
      return unless ratio

      profile.basis == 'implement' ? implement_label(ratio, reference) : barbell_label(ratio, profile, reference)
    end

    def unloaded?(exercise)
      return false if [exercise.load, exercise.male_load, exercise.female_load].any? { |load| load.to_i.positive? }
      return false if LOADED_EQUIPMENT.include?(exercise.movement.equipment)

      !LoadBearingMovement.call(exercise.movement)
    end

    # Prescribed / reference load, on the male side of a sex-split prescription (the model
    # requires both sides whenever either is given).
    def ratio(exercise, profile)
      load = [exercise.load, exercise.male_load].compact.find(&:positive?)
      load.to_f / profile.reference_load if load && profile&.reference_load
    end

    def barbell_label(ratio, profile, reference)
      return 'heavy' if ratio >= reference.constant(:heavy_boundary)

      profile.light_below && ratio < profile.light_below ? 'light' : 'moderate'
    end

    def implement_label(ratio, reference)
      bounds = reference.section(:implement_loading)
      return 'light' if ratio <= bounds.fetch('light_up_to')

      ratio >= bounds.fetch('heavy_from') ? 'heavy' : 'moderate'
    end
  end
end
