module StimulusLearner
  # An exercise's predicted values for every stimulus field it lacks its own value for.
  class ExercisePredictor
    PER_MOVEMENT = %w[stimulus_duration_max stimulus_rest_max_seconds stimulus_effort].freeze

    def initialize(examples)
      @loading = Loading.new(examples)
      @sets = FieldLearner.new(examples, fields: %w[stimulus_sets_max])
      @fields = PER_MOVEMENT.index_with { |field| FieldLearner.new(examples, fields: [field]) }
    end

    def predict(exercise)
      prediction = Prediction.new
      predict_loading(exercise, prediction)
      predict_sets(exercise, prediction)
      @fields.each do |field, learner|
        next unless exercise[field].nil?

        prediction.learned(learner.predict(exercise), confidence(learner.support(exercise)))
      end
      prediction
    end

    private

    def predict_loading(exercise, prediction)
      return unless exercise.stimulus_loading.nil?
      return prediction.ruled(stimulus_loading: 'unloaded') if Loading.unloaded?(exercise)

      prediction.learned(@loading.predict(exercise), confidence(@loading.support(exercise), Loading::MIN_LOADING_EXAMPLES))
    end

    # A sets guide only makes sense alongside a loading value.
    def predict_sets(exercise, prediction)
      return unless exercise.stimulus_sets_max.nil?
      return if exercise.stimulus_loading.nil? && !prediction.values.key?(:stimulus_loading)

      prediction.learned(@sets.predict(exercise), confidence(@sets.support(exercise)))
    end

    def confidence(support, threshold = FieldLearner::MIN_FIELD_EXAMPLES)
      StimulusLearner.confidence(support, threshold)
    end
  end
end
