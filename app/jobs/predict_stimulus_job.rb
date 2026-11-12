# Refits the stimulus learner on CrossFit's extracted examples and writes predictions for
# every workout and exercise that lacks its own stimulus values.
class PredictStimulusJob < ApplicationJob
  queue_as :default

  def perform
    StimulusLearner.call
  end
end
