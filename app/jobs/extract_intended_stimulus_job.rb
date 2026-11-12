# Background entry point for IntendedStimulusBackfill. With then_predict, refreshes the
# learned stimulus predictions once extraction has produced new training examples.
class ExtractIntendedStimulusJob < ApplicationJob
  queue_as :default

  def perform(force: false, then_predict: false)
    IntendedStimulusBackfill.call(force:)
    PredictStimulusJob.perform_later if then_predict
  end
end
