# Runs the intended-stimulus extractor over workouts whose Stimulus and Strategy prose has not
# been structured yet (#1992). Idempotent: the parser stamps every workout it processes
# `extracted`, so a rerun targets nothing new. `authored` workouts are never touched; `force`
# also re-extracts workouts already stamped `extracted` (e.g. after the prompt gains fields).
# One workout's failure (an LLM error, or a legacy row that no longer validates) is counted and
# logged without stopping the rest.
class IntendedStimulusBackfill
  Result = Data.define(:targeted, :extracted, :failed)

  def self.targets(force: false)
    scope = Workout.where.not(intended_stimulus_notes: [nil, ''])
                   .where(stimulus_source: force ? [nil, :extracted] : nil)
    scope.order(:id)
  end

  def self.call(dry_run: false, force: false, logger: Rails.logger)
    targets = self.targets(force:)
    return Result.new(targeted: targets.count, extracted: 0, failed: 0) if dry_run

    extracted = failed = 0
    targets.find_each do |workout|
      WorkoutExtraction::IntendedStimulusParser.call(workout, logger:, force:)
      extracted += 1
    rescue WorkoutExtraction::IntendedStimulusParser::ExtractionError, ActiveRecord::RecordInvalid => e
      failed += 1
      logger&.warn("[IntendedStimulusBackfill] workout #{workout.id}: #{e.message}")
    end
    Result.new(targeted: extracted + failed, extracted:, failed:)
  end
end
