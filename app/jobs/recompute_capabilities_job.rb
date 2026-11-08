# Rebuilds a user's heuristic athlete capabilities. Idempotent: it recomputes from scratch, so
# enqueueing it repeatedly for the same user is harmless.
class RecomputeCapabilitiesJob < ApplicationJob
  queue_as :default

  # Two recomputes for one user racing would collide on the unique indexes and the older snapshot
  # could win; serialize them per user.
  limits_concurrency to: 1, key: ->(user_id) { user_id }

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    CapabilityEstimator.call(user)
  rescue ActiveRecord::InvalidForeignKey
    # The user was deleted while this recompute was running.
    raise if User.exists?(user_id)
  end
end
