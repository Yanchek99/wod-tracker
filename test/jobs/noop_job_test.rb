require 'test_helper'

class NoopJobTest < ActiveJob::TestCase
  test 'enqueues on the default queue' do
    assert_enqueued_with(job: NoopJob, queue: 'default') do
      NoopJob.perform_later
    end
  end

  test 'performs without raising' do
    assert_nothing_raised do
      perform_enqueued_jobs do
        NoopJob.perform_later
      end
    end
  end
end
