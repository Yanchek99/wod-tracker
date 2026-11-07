# Rebuilds a user's heuristic athlete capabilities. Idempotent: it recomputes from scratch, so
# enqueueing it repeatedly for the same user is harmless.
class RecomputeCapabilitiesJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    CapabilityEstimator.call(user)
  end
end
