require 'test_helper'

class StimulusTextFetchTest < ActiveJob::TestCase
  setup do
    @crossfit = Program.create!(name: 'Crossfit.com')
    @posted_at = ActiveSupport::TimeZone['America/Los_Angeles'].local(2025, 6, 18, 18)
  end

  test 'targets Crossfit.com schedules whose workout has no notes' do
    blank = @crossfit.schedules.create!(workout: workouts(:murph), posted_at: @posted_at)
    workouts(:fran).update!(intended_stimulus_notes: 'Already has text.')
    @crossfit.schedules.create!(workout: workouts(:fran), posted_at: @posted_at + 1.day)
    Program.create!(name: 'Some Gym').schedules.create!(workout: workouts(:segmented), posted_at: @posted_at)

    assert_equal [blank], StimulusTextFetch.targets.to_a
  end

  test 'a dry run counts targets and enqueues nothing' do
    @crossfit.schedules.create!(workout: workouts(:murph), posted_at: @posted_at)

    assert_no_enqueued_jobs { assert_equal 1, StimulusTextFetch.call(dry_run: true) }
  end

  test 'enqueues one fetch per target and never an import' do
    schedule = @crossfit.schedules.create!(workout: workouts(:murph), posted_at: @posted_at)

    StimulusTextFetch.call

    assert_enqueued_with(job: FetchStimulusTextJob, args: [schedule.id])
    assert_no_enqueued_jobs(only: ScrapeCfWodJob)
  end
end
