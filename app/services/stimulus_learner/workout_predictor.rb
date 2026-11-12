module StimulusLearner
  # A workout's predicted values for every stimulus field it lacks its own value for. The goal
  # gates the rest: heavy-day targets only for a heavy goal, interval targets only for
  # intervals. Expected time and round time come from learned paces; a weight-scored workout's
  # % of 1RM result range comes from matching examples instead.
  class WorkoutPredictor
    HEAVY_GOALS = %w[heavy_ascending heavy_hold_percent heavy_find_max].freeze
    HEAVY_PAIRS = [
      %w[stimulus_percent_1rm_low stimulus_percent_1rm_high],
      %w[stimulus_working_sets_low stimulus_working_sets_high],
      %w[stimulus_rest_seconds_low stimulus_rest_seconds_high]
    ].freeze
    INTERVAL_FIELDS = %w[stimulus_interval_work_seconds stimulus_interval_rest_seconds_min].freeze

    def initialize(examples)
      @pace = Pace.new(examples)
      @pace_support = examples.workouts.size
      @goal = FieldLearner.new(examples, fields: %w[stimulus_goal])
      @result_range = FieldLearner.new(examples, fields: %w[stimulus_range_low stimulus_range_high])
      @heavy = HEAVY_PAIRS.map { |pair| FieldLearner.new(examples, fields: pair) }
      @interval = INTERVAL_FIELDS.map { |field| FieldLearner.new(examples, fields: [field]) }
    end

    def predict(workout)
      prediction = Prediction.new
      goal = workout.stimulus_goal || learn(workout, prediction, @goal)[:stimulus_goal]
      predict_range(workout, prediction)
      @heavy.each { |learner| learn(workout, prediction, learner) } if HEAVY_GOALS.include?(goal)
      @interval.each { |learner| learn(workout, prediction, learner) } if goal == 'intervals'
      prediction
    end

    private

    def predict_range(workout, prediction)
      return learn(workout, prediction, @result_range) if workout.score_weight?

      predict_paced_range(workout, prediction) if workout.stimulus_range_low.nil? && workout.stimulus_range_high.nil?
    end

    def predict_paced_range(workout, prediction)
      values = @pace.predict(workout)
      values = values.except(:stimulus_round_seconds_low, :stimulus_round_seconds_high) unless round_time_open?(workout)
      prediction.learned(values, StimulusLearner.confidence(@pace_support, Pace::MIN_PACE_EXAMPLES))
    end

    def round_time_open?(workout)
      workout.stimulus_round_seconds_low.nil? && workout.stimulus_round_seconds_high.nil?
    end

    # Predicts with the learner only when none of its fields has the workout's own value.
    def learn(workout, prediction, learner)
      return {} unless learner.fields.all? { |field| workout[field].nil? }

      values = learner.predict(workout)
      prediction.learned(values, StimulusLearner.confidence(learner.support(workout), FieldLearner::MIN_FIELD_EXAMPLES))
      values.transform_keys(&:to_sym)
    end
  end
end
