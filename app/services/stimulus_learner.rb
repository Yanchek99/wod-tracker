# Predicts the intended stimulus for workouts and exercises that lack CrossFit's own (#1992).
# It learns from CrossFit's published Stimulus and Strategy examples (see Examples) and writes
# one current stimulus_predictions row per target (see PredictionWriter). Plain Ruby, no LLM.
module StimulusLearner
  MODEL_VERSION = 'learned-v1'.freeze
  RULES_VERSION = 'rules-v1'.freeze

  Result = Data.define(:workouts_written, :exercises_written, :unchanged, :skipped)

  def self.call(dry_run: false)
    Run.new(Examples.load, dry_run:).call
  end

  # min(1, n / (2 x threshold)), to 3 decimals: half confidence at the minimum example count.
  def self.confidence(support, threshold)
    [support.to_f / (2 * threshold), 1.0].min.round(3)
  end
end
