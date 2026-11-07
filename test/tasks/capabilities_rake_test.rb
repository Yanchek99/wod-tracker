require 'test_helper'
require 'rake'

class CapabilitiesRakeTest < ActiveJob::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?('capabilities:backfill')
    Rake::Task['capabilities:backfill'].reenable
  end

  test 'backfill enqueues one recompute job per user' do
    assert_enqueued_jobs User.count, only: RecomputeCapabilitiesJob do
      capture_io { Rake::Task['capabilities:backfill'].invoke }
    end
  end
end
