module StimulusLearner
  # Predicts a workout's expected result and time per round the way Programming Basics
  # estimates them -- each movement's time times its volume, summed per round and over the
  # rounds -- with each movement's pace learned from CrossFit's own stated ranges. Every
  # labeled For Time example is one equation (sum of volume x pace = its expected time); every
  # labeled rounds-scored AMRAP is one equation for one round (= time cap / expected rounds).
  # Paces are solved jointly with non-negative least squares.
  #
  # A workout gets a prediction only when every movement in it has countable volume and a
  # learned pace; a partial sum would understate the time. Weight-scored and team workouts get
  # none (a weight range is a % of 1RM; team volume is shared), and neither trains paces.
  class Pace
    MIN_PACE_EXAMPLES = 3

    def initialize(examples, min_examples: MIN_PACE_EXAMPLES)
      @min_examples = min_examples
      fit(examples.workouts.filter_map { |workout| equation(workout) })
    end

    def predict(workout)
      return {} unless predictable?(workout)

      workout.amrap? ? predict_amrap(workout) : predict_for_time(workout)
    end

    private

    def predictable?(workout)
      @paces.any? && !workout.score_weight? && !workout.team?
    end

    # [features, target_seconds] for a labeled example, or nil when it can't serve as one.
    def equation(workout)
      target = target_value(workout)
      features = features(workout) unless workout.team?
      return unless target && features

      seconds = target_seconds(workout, target)
      [features, seconds] if seconds
    end

    # A For Time example's expected time, or one round's time for a rounds-scored AMRAP.
    def target_seconds(workout, target)
      return target.to_f if workout.score_time? && !workout.amrap?

      cap = workout.governing_segment&.time_seconds
      cap.to_f / target if workout.amrap? && workout.score_round? && cap
    end

    def target_value(workout)
      low = workout.stimulus_range_low
      high = workout.stimulus_range_high
      return high if low.nil?

      high ? (low + high) / 2.0 : low
    end

    # { [movement_id, unit] => volume } summed across the workout, or nil when any movement's
    # volume can't be counted. An AMRAP segment has no rounds, so for one this is the volume of a
    # single round.
    def features(workout)
      volumes = workout.segments.flat_map(&:exercises).map { |exercise| [exercise.movement_id, Examples.volume(exercise)] }
      return if volumes.empty? || volumes.any? { |_, volume| volume.empty? }

      volumes.each_with_object(Hash.new(0)) { |(movement_id, volume), totals| add_volume(totals, movement_id, volume) }
    end

    def add_volume(totals, movement_id, volume)
      volume.each { |unit, amount| totals[[movement_id, unit]] += amount }
    end

    def fit(equations)
      equations = identifiable(equations)
      @paces = {}
      return if equations.empty?

      columns = equations.flat_map { |features, _| features.keys }.uniq
      rows = design_rows(equations, columns)
      targets = equations.map(&:last)
      solution = Nnls.solve(rows, targets)
      @paces = columns.zip(solution).select { |_, pace| pace.positive? }.to_h
      @relative_spread = relative_spread(rows, targets, solution)
    end

    def design_rows(equations, columns)
      equations.map { |features, _| columns.map { |column| features.fetch(column, 0).to_f } }
    end

    # Drops equations containing a column seen in fewer than min_examples equations, repeating
    # until stable (dropping an equation can push another column under the threshold).
    def identifiable(equations)
      loop do
        counts = equations.flat_map { |features, _| features.keys }.tally
        kept = equations.select { |features, _| features.keys.all? { |column| counts[column] >= @min_examples } }
        return kept if kept.size == equations.size

        equations = kept
      end
    end

    def relative_spread(rows, targets, solution)
      errors = rows.each_with_index.map do |row, i|
        predicted = row.each_with_index.sum { |value, j| value * solution[j] }
        (predicted - targets[i]) / targets[i]
      end
      Math.sqrt(errors.sum { |error| error**2 } / errors.size)
    end

    def seconds_for(features)
      return if features.blank? || features.keys.any? { |column| !@paces.key?(column) }

      features.sum { |column, volume| volume * @paces[column] }
    end

    def predict_for_time(workout)
      return {} unless workout.score_time?

      total = seconds_for(features(workout))
      return {} unless total

      result = bounds(:stimulus_range, total)
      rounds = workout.governing_segment&.rounds
      result.merge!(bounds(:stimulus_round_seconds, total / rounds)) if rounds.to_i > 1
      result
    end

    def predict_amrap(workout)
      cap = workout.governing_segment.time_seconds
      round_seconds = seconds_for(features(workout))
      return {} unless cap && round_seconds&.positive? && workout.score_round?

      rounds = cap / round_seconds
      spread = rounds * @relative_spread
      {
        stimulus_range_low: [(rounds - spread).floor, 1].max,
        stimulus_range_high: (rounds + spread).ceil
      }.merge(bounds(:stimulus_round_seconds, round_seconds))
    end

    def bounds(prefix, value)
      spread = value * @relative_spread
      { "#{prefix}_low": [(value - spread).round, 1].max, "#{prefix}_high": (value + spread).round }
    end
  end
end
