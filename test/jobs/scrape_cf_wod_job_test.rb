require 'test_helper'

class ScrapeCfWodJobTest < ActiveJob::TestCase
  setup do
    @program = Program.create!(name: 'Crossfit.com')
  end

  test 'imports a new workout: creates a Workout and Schedule, no WorkoutImport row' do
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2018/01/10})
      .to_return(status: 200, body: cf_wod_fixture('legacy_with_scaling.html'))

    stub_llm_parser(workouts(:fran)) do
      perform_enqueued_jobs { ScrapeCfWodJob.perform_later(Date.new(2018, 1, 10)) }
    end

    schedule = @program.schedules.find_by!(posted_at: Date.new(2018, 1, 10))
    assert_equal workouts(:fran), schedule.workout
    assert_equal 0, WorkoutImport.count
  end

  test 'calls the LLM parser with the page body text and the resolved date' do
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2018/01/10})
      .to_return(status: 200, body: cf_wod_fixture('legacy_with_scaling.html'))

    received_args = nil
    responder = lambda do |text, date:|
      received_args = [text, date]
      workouts(:fran)
    end
    stub_llm_parser(responder) do
      perform_enqueued_jobs { ScrapeCfWodJob.perform_later(Date.new(2018, 1, 10)) }
    end

    text, date = received_args
    assert_includes text, 'power snatches'
    assert_equal Date.new(2018, 1, 10), date
  end

  test 'passing :heuristic uses CfWod::WorkoutParser instead of the LLM parser' do
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2018/01/10})
      .to_return(status: 200, body: cf_wod_fixture('legacy_with_scaling.html'))

    perform_enqueued_jobs { ScrapeCfWodJob.perform_later(Date.new(2018, 1, 10), :heuristic) }

    workout = Workout.find_by!(name: 'CF-180110')
    schedule = @program.schedules.find_by!(posted_at: Date.new(2018, 1, 10))
    assert_equal workout, schedule.workout
    assert_equal 0, WorkoutImport.count
  end

  test 'falls back to the heuristic parser when the primary llm parser fails' do
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2018/01/10})
      .to_return(status: 200, body: cf_wod_fixture('legacy_with_scaling.html'))

    stub_llm_parser(->(*, **) { raise WorkoutExtraction::LlmParser::ExtractionError, 'llm boom' }) do
      perform_enqueued_jobs { ScrapeCfWodJob.perform_later(Date.new(2018, 1, 10)) }
    end

    workout = Workout.find_by!(name: 'CF-180110')
    schedule = @program.schedules.find_by!(posted_at: Date.new(2018, 1, 10))
    assert_equal workout, schedule.workout
    assert_equal 0, WorkoutImport.count
  end

  test 'falls back to the llm parser when the primary heuristic parser fails' do
    stub_cf_wod_redirect('2026/06/20', '260620')
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/260620})
      .to_return(status: 200, body: cf_wod_fixture('modern_multi_part.html'))

    stub_llm_parser(workouts(:fran)) do
      perform_enqueued_jobs { ScrapeCfWodJob.perform_later(Date.new(2026, 6, 20), :heuristic) }
    end

    schedule = @program.schedules.find_by!(posted_at: Date.new(2026, 6, 20))
    assert_equal workouts(:fran), schedule.workout
    assert_equal 0, WorkoutImport.count
  end

  test 're-running the same date is idempotent: no duplicate Schedule or Workout' do
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2018/01/10})
      .to_return(status: 200, body: cf_wod_fixture('legacy_with_scaling.html'))

    assert_no_difference('Workout.count') do
      stub_llm_parser(workouts(:fran)) do
        2.times { perform_enqueued_jobs { ScrapeCfWodJob.perform_later(Date.new(2018, 1, 10)) } }
      end
    end

    assert_equal 1, @program.schedules.where(posted_at: Date.new(2018, 1, 10)).count
    assert_equal workouts(:fran), @program.schedules.find_by!(posted_at: Date.new(2018, 1, 10)).workout
  end

  test 'a rest day is skipped: no Workout, Schedule, or WorkoutImport row' do
    stub_cf_wod_redirect('2026/07/02', '260702')
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/260702})
      .to_return(status: 200, body: cf_wod_fixture('modern_rest_day.html'))

    perform_enqueued_jobs { ScrapeCfWodJob.perform_later(Date.new(2026, 7, 2)) }

    assert_equal 0, @program.schedules.count
    assert_equal 0, WorkoutImport.count
  end

  test 'logs a WorkoutImport failure with the raw body text when both the primary and fallback parser fail' do
    stub_cf_wod_redirect('2026/06/20', '260620')
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/260620})
      .to_return(status: 200, body: cf_wod_fixture('modern_multi_part.html'))

    stub_llm_parser(->(*, **) { raise WorkoutExtraction::LlmParser::ExtractionError, 'llm boom' }) do
      perform_enqueued_jobs { ScrapeCfWodJob.perform_later(Date.new(2026, 6, 20)) }
    end

    workout_import = WorkoutImport.find_by!(workout_date: Date.new(2026, 6, 20))
    assert workout_import.failed?
    assert_includes workout_import.error_message, 'unrecognized exercise line'
    assert_includes workout_import.raw_text, 'sled drag'
    assert_equal 0, @program.schedules.count
  end

  test 'a fetch failure retries 3 times then logs a WorkoutImport failure with no raw text' do
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2026/07/11}).to_return(status: 500)

    assert_difference('WorkoutImport.count', 1) do
      perform_enqueued_jobs { ScrapeCfWodJob.perform_later(Date.new(2026, 7, 11)) }
    end

    assert_requested(:get, %r{\Ahttps://www\.crossfit\.com/workout/2026/07/11}, times: 3)
    workout_import = WorkoutImport.find_by!(workout_date: Date.new(2026, 7, 11))
    assert workout_import.failed?
    assert_nil workout_import.raw_text
    assert_includes workout_import.error_message, 'Unexpected response 500'
  end

  test 'a persistently empty-template response logs a failure after Fetcher\'s own retries, without stacking additional job-level attempts' do
    shell_html = '<html><body><div id="root"></div></body></html>'
    stub_cf_wod_redirect('2026/07/12', '260712')
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/260712}).to_return(status: 200, body: shell_html)

    assert_difference('WorkoutImport.count', 1) do
      perform_enqueued_jobs { ScrapeCfWodJob.perform_later(Date.new(2026, 7, 12)) }
    end

    assert_requested(:get, %r{\Ahttps://www\.crossfit\.com/260712}, times: 3)
    workout_import = WorkoutImport.find_by!(workout_date: Date.new(2026, 7, 12))
    assert workout_import.failed?
  end

  test 'an error persisting after a successful parse (e.g. the Program missing) still logs a WorkoutImport failure' do
    @program.destroy!
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2018/01/10})
      .to_return(status: 200, body: cf_wod_fixture('legacy_with_scaling.html'))

    stub_llm_parser(workouts(:fran)) do
      perform_enqueued_jobs { ScrapeCfWodJob.perform_later(Date.new(2018, 1, 10)) }
    end

    workout_import = WorkoutImport.find_by!(workout_date: Date.new(2018, 1, 10))
    assert workout_import.failed?
    assert_includes workout_import.error_message, "Couldn't find Program"
  end

  test 'clears a stale failed WorkoutImport row once the date is later imported successfully' do
    WorkoutImport.create!(workout_date: Date.new(2018, 1, 10), status: :failed, error_message: 'previous failure')
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2018/01/10})
      .to_return(status: 200, body: cf_wod_fixture('legacy_with_scaling.html'))

    stub_llm_parser(workouts(:fran)) do
      perform_enqueued_jobs { ScrapeCfWodJob.perform_later(Date.new(2018, 1, 10)) }
    end

    assert_equal 0, WorkoutImport.count
  end

  test 'perform resolves and pins the default date onto job.arguments so a later invocation reuses it' do
    job = ScrapeCfWodJob.new

    travel_to Time.utc(2026, 1, 15, 12, 0, 0) do # noon UTC = 4am PST Jan 15 -> default_date (tomorrow PT) = Jan 16
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2026/01/16}).to_return(status: 500)

      assert_raises(CfWod::Fetcher::FetchError) { job.perform }
    end

    assert_equal [Date.new(2026, 1, 16), :llm], job.arguments

    travel_to Time.utc(2026, 1, 17, 12, 0, 0) do # two days later -- a freshly recomputed default would be Jan 18
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2026/01/16})
        .to_return(status: 200, body: cf_wod_fixture('legacy_with_scaling.html'))

      stub_llm_parser(workouts(:fran)) { job.perform(*job.arguments) }
    end

    assert_equal workouts(:fran), @program.schedules.find_by!(posted_at: Date.new(2026, 1, 16)).workout
  end
end
