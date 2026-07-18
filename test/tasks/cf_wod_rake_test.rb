require 'test_helper'
require 'rake'

class CfWodRakeTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task['cf_wod:fetch'].reenable
    Rake::Task['cf_wod:scrape'].reenable
    Rake::Task['cf_wod:backfill'].reenable
  end

  test 'fetches, parses, and prints a workout for a given date' do
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2018/01/10})
      .to_return(status: 200, body: Rails.root.join('test/fixtures/cf_wod/legacy_with_scaling.html').read)

    output = capture_io { Rake::Task['cf_wod:fetch'].invoke('2018-01-10') }.join

    assert_includes output, 'slug="180110"'
    assert_includes output, 'name: "CF-180110"'
  end

  test 'aborts with a usage message when no date is given' do
    error = assert_raises(SystemExit) { Rake::Task['cf_wod:fetch'].invoke }

    assert_equal 1, error.status
  end

  test 'aborts with the fetch error message on a failed fetch' do
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2030/01/01}).to_return(status: 404)

    error = assert_raises(SystemExit) { Rake::Task['cf_wod:fetch'].invoke('2030-01-01') }

    assert_equal 1, error.status
  end

  test 'aborts with the parse error message on an unparseable workout' do
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2026/06/20})
      .to_return(status: 301, headers: { 'Location' => '/260620' })
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/260620})
      .to_return(status: 200, body: Rails.root.join('test/fixtures/cf_wod/modern_multi_part.html').read)

    error = assert_raises(SystemExit) { Rake::Task['cf_wod:fetch'].invoke('2026-06-20') }

    assert_equal 1, error.status
  end

  test 'scrape persists a Workout and Schedule for a given date' do
    program = Program.create!(name: 'Crossfit.com')
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2018/01/10})
      .to_return(status: 200, body: Rails.root.join('test/fixtures/cf_wod/legacy_with_scaling.html').read)

    output = stub_llm_parser(workouts(:fran)) do
      capture_io { Rake::Task['cf_wod:scrape'].invoke('2018-01-10') }.join
    end

    assert_includes output, 'Scraped 2018-01-10 successfully'
    assert_equal workouts(:fran), program.schedules.find_by!(posted_at: Date.new(2018, 1, 10)).workout
  end

  test 'scrape aborts with a usage message when no date is given' do
    error = assert_raises(SystemExit) { Rake::Task['cf_wod:scrape'].invoke }

    assert_equal 1, error.status
  end

  test 'scrape aborts with the WorkoutImport failure message on an unparseable workout' do
    Program.create!(name: 'Crossfit.com')
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2026/06/20})
      .to_return(status: 301, headers: { 'Location' => '/260620' })
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/260620})
      .to_return(status: 200, body: Rails.root.join('test/fixtures/cf_wod/modern_multi_part.html').read)

    error = stub_llm_parser(->(*, **) { raise WorkoutExtraction::LlmParser::ExtractionError, 'unable to parse workout' }) do
      assert_raises(SystemExit) { Rake::Task['cf_wod:scrape'].invoke('2026-06-20') }
    end

    assert_equal 1, error.status
  end

  test 'backfill enqueues ScrapeCfWodJob for each date in the range and reports the count' do
    output = capture_io { Rake::Task['cf_wod:backfill'].invoke('2026-01-01', '2026-01-03') }.join

    assert_includes output, 'Enqueued 3 days (2026-01-01..2026-01-03) for backfill'
  end

  test 'backfill aborts with a usage message when a date is missing' do
    error = assert_raises(SystemExit) { Rake::Task['cf_wod:backfill'].invoke('2026-01-01') }

    assert_equal 1, error.status
    assert_includes error.message, 'Usage:'
  end

  test 'backfill aborts with the range error message when start is after end' do
    error = assert_raises(SystemExit) { Rake::Task['cf_wod:backfill'].invoke('2026-01-03', '2026-01-01') }

    assert_equal 1, error.status
    assert_includes error.message, 'start_date must be <= end_date'
  end
end
