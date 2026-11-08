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

  test 'a foreign key failure because the user was deleted mid-run is ignored, otherwise it raises' do
    user = User.create!(email: 'gone@wod-tracker.com', password: 'password123', first_name: 'A', last_name: 'B', weight: 150, sex: :female)
    original = CapabilityEstimator.method(:call)
    CapabilityEstimator.define_singleton_method(:call) { |target, **| target.destroy! && raise(ActiveRecord::InvalidForeignKey) }

    assert_nothing_raised { RecomputeCapabilitiesJob.perform_now(user.id) }

    survivor = users(:mathew)
    CapabilityEstimator.define_singleton_method(:call) { |_target, **| raise ActiveRecord::InvalidForeignKey }
    assert_raises(ActiveRecord::InvalidForeignKey) { RecomputeCapabilitiesJob.perform_now(survivor.id) }
  ensure
    CapabilityEstimator.define_singleton_method(:call, original)
  end
end
