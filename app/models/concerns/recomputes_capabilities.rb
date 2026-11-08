# Keeps a user's heuristic athlete capabilities fresh: any commit on a log (including a touch from
# one of its movement logs) enqueues a from-scratch recompute for the log's user.
module RecomputesCapabilities
  extend ActiveSupport::Concern

  included do
    after_commit :enqueue_capability_recompute
  end

  private

  def enqueue_capability_recompute
    return if Current.defer_capability_recompute
    # Deleting a user cascades to their logs; there is nothing left to recompute.
    return if destroyed_by_association&.active_record == User

    RecomputeCapabilitiesJob.perform_later(user_id)
  end
end
