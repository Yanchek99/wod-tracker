require 'test_helper'

module CfWod
  class WorkoutParserCorpusTest < ActiveSupport::TestCase
    FIXTURES = Rails.root.join('test/fixtures/cf_wod')

    def fixture(name)
      File.read(FIXTURES.join(name))
    end

    def wod_page(slug:, body_text:)
      WodPage.new(date: nil, slug: slug, title: nil, body_html: nil, body_text: body_text, description: nil,
                  scaling: nil, rest_day: false, previous_slug: nil, next_slug: nil)
    end

    test '180110: AMRAP with a load shared across two movements, excluding the bodyweight rope climb' do
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2018/01/10})
        .to_return(status: 200, body: fixture('legacy_with_scaling.html'))

      page = Fetcher.call(Date.new(2018, 1, 10))
      workout = WorkoutParser.call(page)

      assert workout.valid?
      assert_equal 'CF-180110', workout.name
      assert_equal 'rep', workout.score_type
      assert_equal 10, workout.time
      assert_equal 3, workout.exercises.length

      snatch, lunge, rope_climb = workout.exercises.sort_by(&:position)
      assert_equal movements(:power_snatch), snatch.movement
      assert_equal [5, 65, 95], [snatch.reps, snatch.female_load, snatch.male_load]
      assert_equal movements(:overhead_walking_lunge), lunge.movement
      assert_equal [10, 65, 95], [lunge.reps, lunge.female_load, lunge.male_load]
      assert_equal movements(:rope_climb), rope_climb.movement
      assert_equal 1, rope_climb.reps
      assert_nil rope_climb.female_load
    end

    test '260620: a real instructional sentence embedded in the body fails closed rather than guessing' do
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/260620})
        .to_return(status: 200, body: fixture('modern_multi_part.html'))
      stub_request(:get, %r{\Ahttps://www\.crossfit\.com/workout/2026/06/20})
        .to_return(status: 301, headers: { 'Location' => '/260620' })

      page = Fetcher.call(Date.new(2026, 6, 20))

      error = assert_raises(WorkoutParser::UnparseableError) { WorkoutParser.call(page) }
      assert_includes error.message, 'Any time you stop'
    end

    test 'Fran: rep-ladder with a bare-movement-only line, load applies to the thruster but not the pull-up' do
      page = wod_page(slug: '300201', body_text: "21-15-9 reps for time of:\nThrusters\nPull-ups\n\nMen: 95 lb.\nWomen: 65 lb.")

      workout = WorkoutParser.call(page)

      assert workout.valid?
      assert_equal 'time', workout.score_type
      assert_equal '21-15-9', workout.interval
      thruster, pull_up = workout.exercises.sort_by(&:position)
      assert_equal movements(:thruster), thruster.movement
      assert_equal [1, 65, 95], [thruster.reps, thruster.female_load, thruster.male_load]
      assert_equal movements(:pull_up), pull_up.movement
      assert_equal 1, pull_up.reps
      assert_nil pull_up.female_load
    end
  end
end
