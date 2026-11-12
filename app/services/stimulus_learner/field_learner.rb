module StimulusLearner
  # Learns one stimulus field (or one low/high pair) from CrossFit's labeled examples that
  # share the target's structure (Structure.workout_key / exercise_key). Categorical fields take
  # the majority label; a numeric pair takes the interquartile range of the examples' values; a
  # single numeric field takes their median. Below min_examples matching examples it predicts
  # nothing.
  class FieldLearner
    MIN_FIELD_EXAMPLES = 5
    CATEGORICAL = %w[stimulus_goal stimulus_effort stimulus_loading].freeze

    attr_reader :fields

    def initialize(examples, fields:, min_examples: MIN_FIELD_EXAMPLES)
      @fields = fields.map(&:to_s)
      @min_examples = min_examples
      @exercise_level = Exercise::STIMULUS_FIELDS.include?(@fields.first)
      records = @exercise_level ? examples.exercises : examples.workouts
      @groups = records.select { |record| @fields.any? { |field| !record[field].nil? } }
                       .group_by { |record| key(record) }
    end

    def predict(target)
      matches = @groups.fetch(key(target), [])
      return {} if matches.size < @min_examples

      if CATEGORICAL.include?(@fields.first)
        { @fields.first.to_sym => majority(matches) }
      elsif @fields.size == 2
        pair(matches)
      else
        { @fields.first.to_sym => median(matches.pluck(@fields.first)) }
      end
    end

    def support(target)
      @groups.fetch(key(target), []).size
    end

    private

    def key(record)
      @exercise_level ? Structure.exercise_key(record) : Structure.workout_key(record)
    end

    def majority(matches)
      matches.pluck(@fields.first).tally.max_by { |_, count| count }.first
    end

    def pair(matches)
      low_field, high_field = @fields
      values = matches.flat_map { |record| [record[low_field], record[high_field]] }.compact.sort
      { low_field.to_sym => percentile(values, 0.25).round, high_field.to_sym => percentile(values, 0.75).round }
    end

    def median(values)
      percentile(values.compact.sort, 0.5).round
    end

    def percentile(sorted, fraction)
      position = (sorted.size - 1) * fraction
      lower = sorted[position.floor]
      upper = sorted[position.ceil]
      lower + ((upper - lower) * (position - position.floor))
    end
  end
end
