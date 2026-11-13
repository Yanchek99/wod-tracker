module StimulusCalculator
  # How heavy a movement should feel: prescribed load against the reference athlete's reference
  # load for that movement. Light below the lift class's boundary, heavy at or above the heavy
  # boundary (L2: heavy-day working sets at or above 80-85% of 1RM), moderate in between.
  # Body weight only (no load, no loaded equipment) is unloaded, per CrossFit's definition.
  module Loading
    LOADED_EQUIPMENT = %w[barbell dumbbell kettlebell medicine_ball sandbag vest plate sled].freeze

    module_function

    def call(exercise, reference)
      return 'unloaded' if unloaded?(exercise)

      ratio = ratio(exercise, reference)
      return unless ratio

      label(ratio, reference.movement(exercise.movement.name).lift_class, reference)
    end

    def unloaded?(exercise)
      return false if [exercise.load, exercise.male_load, exercise.female_load].any? { |load| load.to_i.positive? }
      return false if LOADED_EQUIPMENT.include?(exercise.movement.equipment)

      !LoadBearingMovement.call(exercise.movement)
    end

    # Prescribed / reference load, on the male side of a sex-split prescription (the model
    # requires both sides whenever either is given).
    def ratio(exercise, reference)
      entry = reference.movement(exercise.movement.name)
      load = [exercise.load, exercise.male_load].compact.find(&:positive?)
      load.to_f / entry.reference_load if load && entry&.reference_load
    end

    def label(ratio, lift_class, reference)
      return 'heavy' if ratio >= reference.constant(:heavy_boundary)

      boundary = reference.light_boundary(lift_class)
      boundary && ratio < boundary ? 'light' : 'moderate'
    end
  end
end
