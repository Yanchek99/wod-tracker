require 'test_helper'

class LogCapabilityRecomputeTest < ActiveJob::TestCase
  setup do
    @user = users(:brooke)
    @log = logs(:brooke_fran)
  end

  test 'creating a log enqueues a recompute for its user' do
    assert_enqueued_with(job: RecomputeCapabilitiesJob, args: [@user.id]) do
      workouts(:fran).logs.create!(user: @user, score_type: :time, score_value: 300)
    end
  end

  test 'updating a log enqueues a recompute' do
    assert_enqueued_with(job: RecomputeCapabilitiesJob, args: [@user.id]) { @log.update!(score_value: 320) }
  end

  test 'destroying a log enqueues a recompute' do
    assert_enqueued_with(job: RecomputeCapabilitiesJob, args: [@user.id]) { @log.destroy! }
  end

  test 'changing only a nested movement log still enqueues a recompute' do
    movement_log = @log.movement_logs.first

    assert_enqueued_with(job: RecomputeCapabilitiesJob, args: [@user.id]) do
      movement_log.update!(load: 95)
    end
  end

  test 'bulk imports can defer the recompute' do
    assert_no_enqueued_jobs only: RecomputeCapabilitiesJob do
      Current.set(defer_capability_recompute: true) do
        workouts(:fran).logs.create!(user: @user, score_type: :time, score_value: 300)
      end
    end
  end
end
