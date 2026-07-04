require 'test_helper'
require 'rake'

class CfWodRakeTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task['cf_wod:fetch'].reenable
  end

  test 'fetches, parses, and prints a WOD for a given date' do
    stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2018/01/10})
      .to_return(status: 200, body: Rails.root.join('test/fixtures/cf_wod/legacy_with_scaling.html').read)

    output = capture_io { Rake::Task['cf_wod:fetch'].invoke('2018-01-10') }.join

    assert_includes output, 'CfWod::ParseResult'
    assert_includes output, 'name: "Workout of the Day: Wednesday 180110"'
    assert_includes output, 'status=:partial'
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
end
