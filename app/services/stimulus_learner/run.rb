module StimulusLearner
  # One learner pass: predict every workout and exercise, then write (or, on a dry run, count)
  # the predictions.
  class Run
    def initialize(examples, dry_run:)
      @dry_run = dry_run
      @workouts = WorkoutPredictor.new(examples)
      @exercises = ExercisePredictor.new(examples)
      @counts = Hash.new(0)
    end

    def call
      Workout.includes(segments: { exercises: %i[movement stimulus_predictions] }, stimulus_predictions: [])
             .find_each do |workout|
        record(:workouts_written, workout, @workouts.predict(workout))
        workout.segments.flat_map(&:exercises).each do |exercise|
          record(:exercises_written, exercise, @exercises.predict(exercise))
        end
      end
      Result.new(**Result.members.index_with { |member| @counts[member] })
    end

    private

    def record(counter, target, prediction)
      outcome = write(target, prediction)
      @counts[outcome == :created ? counter : outcome] += 1
    end

    def write(target, prediction)
      @dry_run ? PredictionWriter.outcome(target, prediction) : PredictionWriter.write(target, prediction)
    end
  end
end
