class Current < ActiveSupport::CurrentAttributes
  attribute :user
  # Set by bulk imports that enqueue one capability recompute per user when they finish.
  attribute :defer_capability_recompute
end
