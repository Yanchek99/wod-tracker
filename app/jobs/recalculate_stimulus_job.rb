# Background entry point for StimulusRecalculation (the RailsAdmin "Recalculate stimulus" step).
class RecalculateStimulusJob < ApplicationJob
  queue_as :default

  def perform
    StimulusRecalculation.call
  end
end
