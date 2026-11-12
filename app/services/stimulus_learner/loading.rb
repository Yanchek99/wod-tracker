module StimulusLearner
  # Predicts an exercise's loading (light/moderate/heavy) from the loads CrossFit labeled for
  # the same movement. Per movement only: no fallback to movement groups. Between two adjacent
  # labels the boundary is the midpoint of the gap between them (or of their medians when the
  # label groups overlap). It never extrapolates past the lightest label unless that label is
  # light, or past the heaviest unless that label is heavy.
  class Loading
    MIN_LOADING_EXAMPLES = 5
    ORDER = %w[light moderate heavy].freeze
    LOADED_EQUIPMENT = %w[barbell dumbbell kettlebell medicine_ball sandbag vest plate sled].freeze

    # Body weight only, per CrossFit's definition of unloaded: no prescribed load on a movement
    # that takes no external load.
    def self.unloaded?(exercise)
      return false if load_for(exercise) || exercise.female_load.present?
      return false if LOADED_EQUIPMENT.include?(exercise.movement.equipment)

      !LoadBearingMovement.call(exercise.movement)
    end

    def self.load_for(exercise)
      [exercise.load, exercise.male_load].compact.find(&:positive?)
    end

    def initialize(examples, min_examples: MIN_LOADING_EXAMPLES)
      @min_examples = min_examples
      @loads_by_movement = examples.exercises.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |example, index|
        load = self.class.load_for(example)
        next unless load && ORDER.include?(example.stimulus_loading)

        index[example.movement_id] << [example.stimulus_loading, load]
      end
    end

    def predict(exercise)
      load = self.class.load_for(exercise)
      labeled = @loads_by_movement[exercise.movement_id]
      return {} if load.nil? || labeled.size < @min_examples

      label = label_for(load, labeled.group_by(&:first).transform_values { |pairs| pairs.map(&:last).sort })
      label ? { stimulus_loading: label } : {}
    end

    def support(exercise)
      @loads_by_movement.fetch(exercise.movement_id, []).size
    end

    private

    def label_for(load, groups)
      labels = ORDER.select { |label| groups.key?(label) }
      return if beyond_labels?(load, groups, labels)

      labels.each_cons(2) do |lighter, heavier|
        return lighter if load < boundary(groups[lighter], groups[heavier])
      end
      labels.last
    end

    def beyond_labels?(load, groups, labels)
      (load < groups[labels.first].first && labels.first != 'light') ||
        (load > groups[labels.last].last && labels.last != 'heavy')
    end

    def boundary(lighter, heavier)
      return (lighter.last + heavier.first) / 2.0 if lighter.last < heavier.first

      (median(lighter) + median(heavier)) / 2.0
    end

    def median(sorted)
      mid = sorted.size / 2
      sorted.size.odd? ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2.0
    end
  end
end
