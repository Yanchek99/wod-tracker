require 'test_helper'

class RecomputeCapabilitiesJobTest < ActiveJob::TestCase
  test 'rebuilds heuristic capabilities for the user and is idempotent' do
    user = users(:brooke)
    user.athlete_capabilities.source_heuristic.delete_all
    log = logs(:brooke_fran)
    log.movement_logs.find_by(movement: movements(:pullup)).update!(reps: 1)

    2.times { RecomputeCapabilitiesJob.perform_now(user.id) }

    pullup_rows = user.athlete_capabilities.source_heuristic.where(movement: movements(:pullup), kind: :unbroken)
    assert_equal 1, pullup_rows.count
  end

  test 'does nothing for a user deleted after enqueue' do
    assert_nothing_raised { RecomputeCapabilitiesJob.perform_now(0) }
  end

  test 'recomputes for one user never run concurrently' do
    assert_equal 1, RecomputeCapabilitiesJob.concurrency_limit
  end
end
