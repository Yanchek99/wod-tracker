require 'test_helper'

class BackfillCrossfitWodsJobTest < ActiveJob::TestCase
  test 'enqueues one ScrapeCfWodJob per date in the range, staggered by DELAY_BETWEEN_REQUESTS' do
    travel_to Time.utc(2026, 1, 1, 12, 0, 0) do
      BackfillCrossfitWodsJob.perform_now(Date.new(2026, 1, 1), Date.new(2026, 1, 3))

      [Date.new(2026, 1, 1), Date.new(2026, 1, 2), Date.new(2026, 1, 3)].each_with_index do |date, i|
        assert_enqueued_with(job: ScrapeCfWodJob, args: [date],
                             at: (i * BackfillCrossfitWodsJob::DELAY_BETWEEN_REQUESTS).from_now)
      end
    end
  end

  test 'raises ArgumentError for a reversed range, enqueueing nothing' do
    assert_no_enqueued_jobs do
      assert_raises(ArgumentError) do
        BackfillCrossfitWodsJob.perform_now(Date.new(2026, 1, 3), Date.new(2026, 1, 1))
      end
    end
  end

  test 'a 3-day range imports the right count idempotently, isolating a mid-range failure' do
    program = Program.create!(name: 'Crossfit.com')
    # ScrapeCfWodJob defaults to the LLM parser, stubbed here to the same persisted fixture on
    # every call; both successful days -- and a re-run of the whole range -- land on that one
    # Workout row, so this proves the two schedules share a single underlying Workout.
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2018/01/10})
      .to_return(status: 200, body: cf_wod_fixture('legacy_with_scaling.html'))
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2018/01/11}).to_return(status: 500)
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2018/01/12})
      .to_return(status: 200, body: cf_wod_fixture('legacy_with_scaling.html'))

    stub_llm_parser(workouts(:fran)) do
      perform_enqueued_jobs { BackfillCrossfitWodsJob.perform_later(Date.new(2018, 1, 10), Date.new(2018, 1, 12)) }
    end

    schedules = program.schedules.where(posted_at: [Date.new(2018, 1, 10), Date.new(2018, 1, 12)])
    assert_equal 2, schedules.count
    assert_equal [workouts(:fran).id], schedules.map(&:workout_id).uniq
    workout_import = WorkoutImport.find_by!(workout_date: Date.new(2018, 1, 11))
    assert workout_import.failed?

    # Re-run: idempotent, no duplicates, failing day still isolated
    stub_llm_parser(workouts(:fran)) do
      perform_enqueued_jobs { BackfillCrossfitWodsJob.perform_later(Date.new(2018, 1, 10), Date.new(2018, 1, 12)) }
    end

    schedules = program.schedules.where(posted_at: [Date.new(2018, 1, 10), Date.new(2018, 1, 12)])
    assert_equal 2, schedules.count
    assert_equal [workouts(:fran).id], schedules.map(&:workout_id).uniq
    assert_equal 1, WorkoutImport.count
  end
end
