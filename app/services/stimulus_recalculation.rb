# Writes StimulusCalculator's values for every workout and exercise as their current
# stimulus_predictions row (`derived`, `calc-v1`), limited to the fields each record has no own
# authored or extracted value for. Rows from earlier methods are replaced or retired. Reads only
# the database and the reference table: no network, no LLM.
class StimulusRecalculation
  MODEL_VERSION = 'calc-v1'.freeze

  Result = Data.define(:workouts_written, :exercises_written, :unchanged, :retired, :skipped)

  def self.call(dry_run: false, reference: StimulusReference.current)
    new(dry_run:, reference:).call
  end

  def initialize(dry_run:, reference:)
    @dry_run = dry_run
    @reference = reference
    @counts = Hash.new(0)
  end

  def call
    Workout.includes(segments: { exercises: :movement }).find_each do |workout|
      record(:workouts_written, workout, StimulusCalculator.workout(workout, @reference))
      workout.segments.flat_map(&:exercises).each do |exercise|
        record(:exercises_written, exercise, StimulusCalculator.exercise(exercise, @reference))
      end
    end
    Result.new(**Result.members.index_with { |member| @counts[member] })
  end

  private

  def record(counter, target, values)
    open_values = values.select { |field, _| target[field].nil? }
    row = StimulusPredictionWriter::Row.new(values: open_values, source: :derived, model_version: MODEL_VERSION,
                                            confidence: nil)
    outcome = @dry_run ? StimulusPredictionWriter.outcome(target, row) : StimulusPredictionWriter.write(target, row)
    @counts[outcome == :created ? counter : outcome] += 1
  end
end
