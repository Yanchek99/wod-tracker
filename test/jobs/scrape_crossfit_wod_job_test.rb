require 'test_helper'

class ScrapeCrossfitWodJobTest < ActiveJob::TestCase
  setup do
    @program = Program.create!(name: 'Crossfit.com')
  end

  test 'imports a new WOD: creates a Workout and Schedule, no WodImport row' do
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2018/01/10})
      .to_return(status: 200, body: cf_wod_fixture('legacy_with_scaling.html'))

    perform_enqueued_jobs { ScrapeCrossfitWodJob.perform_later(Date.new(2018, 1, 10)) }

    workout = Workout.find_by!(name: 'CF-180110')
    schedule = @program.schedules.find_by!(posted_at: Date.new(2018, 1, 10))
    assert_equal workout, schedule.workout
    assert_equal 0, WodImport.count
  end

  test 're-running the same date is idempotent: no duplicate Schedule or Workout' do
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2018/01/10})
      .to_return(status: 200, body: cf_wod_fixture('legacy_with_scaling.html'))

    2.times { perform_enqueued_jobs { ScrapeCrossfitWodJob.perform_later(Date.new(2018, 1, 10)) } }

    assert_equal 1, @program.schedules.where(posted_at: Date.new(2018, 1, 10)).count
    assert_equal 1, Workout.where(name: 'CF-180110').count
  end

  test 'a rest day is skipped: no Workout, Schedule, or WodImport row' do
    stub_cf_wod_redirect('2026/07/02', '260702')
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/260702})
      .to_return(status: 200, body: cf_wod_fixture('modern_rest_day.html'))

    perform_enqueued_jobs { ScrapeCrossfitWodJob.perform_later(Date.new(2026, 7, 2)) }

    assert_equal 0, @program.schedules.count
    assert_equal 0, WodImport.count
  end

  test 'an unparseable WOD logs a WodImport failure with the raw body text' do
    stub_cf_wod_redirect('2026/06/20', '260620')
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/260620})
      .to_return(status: 200, body: cf_wod_fixture('modern_multi_part.html'))

    perform_enqueued_jobs { ScrapeCrossfitWodJob.perform_later(Date.new(2026, 6, 20)) }

    wod_import = WodImport.find_by!(wod_date: Date.new(2026, 6, 20))
    assert wod_import.failed?
    assert_includes wod_import.error_message, 'Any time you stop'
    assert_includes wod_import.raw_text, 'sled drag'
    assert_equal 0, @program.schedules.count
  end

  test 'a fetch failure retries 3 times then logs a WodImport failure with no raw text' do
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2026/07/11}).to_return(status: 500)

    assert_difference('WodImport.count', 1) do
      perform_enqueued_jobs { ScrapeCrossfitWodJob.perform_later(Date.new(2026, 7, 11)) }
    end

    assert_requested(:get, %r{\Ahttps://www\.crossfit\.com/workout/2026/07/11}, times: 3)
    wod_import = WodImport.find_by!(wod_date: Date.new(2026, 7, 11))
    assert wod_import.failed?
    assert_nil wod_import.raw_text
    assert_includes wod_import.error_message, 'Unexpected response 500'
  end

  test 'a persistently empty-template response logs a failure after Fetcher\'s own retries, without stacking additional job-level attempts' do
    shell_html = '<html><body><div id="root"></div></body></html>'
    stub_cf_wod_redirect('2026/07/12', '260712')
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/260712}).to_return(status: 200, body: shell_html)

    assert_difference('WodImport.count', 1) do
      perform_enqueued_jobs { ScrapeCrossfitWodJob.perform_later(Date.new(2026, 7, 12)) }
    end

    assert_requested(:get, %r{\Ahttps://www\.crossfit\.com/260712}, times: 3)
    wod_import = WodImport.find_by!(wod_date: Date.new(2026, 7, 12))
    assert wod_import.failed?
  end

  test 'an error persisting after a successful parse (e.g. the Program missing) still logs a WodImport failure' do
    @program.destroy!
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2018/01/10})
      .to_return(status: 200, body: cf_wod_fixture('legacy_with_scaling.html'))

    perform_enqueued_jobs { ScrapeCrossfitWodJob.perform_later(Date.new(2018, 1, 10)) }

    wod_import = WodImport.find_by!(wod_date: Date.new(2018, 1, 10))
    assert wod_import.failed?
    assert_includes wod_import.error_message, "Couldn't find Program"
  end

  test 'clears a stale failed WodImport row once the date is later imported successfully' do
    WodImport.create!(wod_date: Date.new(2018, 1, 10), status: :failed, error_message: 'previous failure')
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2018/01/10})
      .to_return(status: 200, body: cf_wod_fixture('legacy_with_scaling.html'))

    perform_enqueued_jobs { ScrapeCrossfitWodJob.perform_later(Date.new(2018, 1, 10)) }

    assert_equal 0, WodImport.count
  end

  test 'perform resolves and pins the default date onto job.arguments so a later invocation reuses it' do
    job = ScrapeCrossfitWodJob.new

    travel_to Time.utc(2026, 1, 15, 12, 0, 0) do # noon UTC = 4am PST Jan 15 -> default_date (tomorrow PT) = Jan 16
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2026/01/16}).to_return(status: 500)

      assert_raises(CfWod::Fetcher::FetchError) { job.perform }
    end

    assert_equal [Date.new(2026, 1, 16)], job.arguments

    travel_to Time.utc(2026, 1, 17, 12, 0, 0) do # two days later -- a freshly recomputed default would be Jan 18
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2026/01/16})
        .to_return(status: 200, body: cf_wod_fixture('legacy_with_scaling.html'))

      job.perform(*job.arguments)
    end

    assert Workout.exists?(name: 'CF-260116')
  end
end
