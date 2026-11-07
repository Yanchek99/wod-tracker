# Keeps a user's heuristic athlete capabilities fresh: any commit on a log (including a touch from
# one of its movement logs) enqueues a from-scratch recompute for the log's user.
module RecomputesCapabilities
  extend ActiveSupport::Concern

  included do
    after_commit :enqueue_capability_recompute
  end

  private

  def enqueue_capability_recompute
    RecomputeCapabilitiesJob.perform_later(user_id)
  end
end
