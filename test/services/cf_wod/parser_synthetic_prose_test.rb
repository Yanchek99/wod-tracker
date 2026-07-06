require 'test_helper'

module CfWod
  class ParserSyntheticProseTest < ActiveSupport::TestCase
    # Not in test/fixtures/movements.yml: their names collide with helper tests elsewhere that
    # create these same names at runtime expecting them to be new. Created here instead, scoped
    # to this file's per-test transactions.
    setup do
      Movement.find_or_create_by!(name: 'Wall-ball Shot')
      Movement.find_or_create_by!(name: 'Box Jump')
      Movement.find_or_create_by!(name: 'Deadlift')
      Movement.find_or_create_by!(name: 'Bike')
    end

    def page_for_text(body_text)
      WodPage.new(date: Date.current, slug: 'x', title: 'x', body_html: body_text, body_text: body_text,
                  description: nil, scaling: nil, rest_day: false, previous_slug: nil, next_slug: nil)
    end

    test 'a body opening with an already-seeded workout name returns that workout directly, unparsed' do
      text = "Fran\n\n21-15-9 reps for time of\nThrusters (95/65 lb)\nPull-ups"

      assert_no_difference(['Movement.count', 'Workout.count']) do
        result = WorkoutParser.call(page_for_text(text))

        assert result.parsed?
        assert_nil result.reason
        assert_equal workouts(:fran), result.workout
      end
    end

    test 'Cindy-shaped AMRAP prose parses cleanly except for an ambiguous bare movement' do
      result = WorkoutParser.call(page_for_text("As many rounds as possible in 20 minutes of\n5 pull-ups\n10 push-ups\n15 squats"))

      assert result.partial?
      assert_includes result.reason, 'squats'
      assert_equal 'rep', result.workout.score_type
      assert_equal 20, result.workout.time
      assert_equal([movements(:pullup), movements(:pushup)], result.workout.exercises.map(&:movement))
    end

    test 'Chelsea-shaped EMOM prose sets rounds and time from the interval and total duration' do
      result = WorkoutParser.call(page_for_text("Every minute on the minute for 30 minutes\n5 pull-ups\n10 push-ups\n15 squats"))

      assert result.partial?
      assert_equal 'rep', result.workout.score_type
      assert_equal 30, result.workout.time
      assert_equal 30, result.workout.rounds
    end

    test 'Fran-shaped interval prose sets both interval and score_type, with a same-line gendered load' do
      result = WorkoutParser.call(page_for_text("21-15-9 reps for time of\nThrusters (95/65 lb)\nPull-ups"))

      assert result.parsed?
      assert_nil result.reason
      workout = result.workout
      assert_equal 'time', workout.score_type
      assert_equal '21-15-9', workout.interval
      thruster = workout.exercises.find { |exercise| exercise.movement.name == 'Thruster' }
      assert_equal 1, thruster.reps
      assert_equal 65, thruster.female_load
      assert_equal 95, thruster.male_load
    end

    test 'a 1RM lifting prescription sets score_type weight and a time cap in seconds' do
      result = WorkoutParser.call(page_for_text("Establish a 1-rep-max clean and jerk within 6 minutes.\n\nClean and Jerk"))

      assert result.parsed?
      assert_equal 'weight', result.workout.score_type
      assert_equal 360, result.workout.time_cap_seconds
    end

    test 'an ascending-ladder cue is not silently modeled as a fixed AMRAP' do
      text = "As many rounds as possible in 7 minutes of\n3 thrusters\n3 chest-to-bar pull-ups\nAdd 3 reps to each movement every round."
      result = WorkoutParser.call(page_for_text(text))

      assert result.partial?
      assert_not result.workout.ascending_ladder?
    end

    test 'a partner/team mention is flagged rather than silently dropped' do
      result = WorkoutParser.call(page_for_text("For time, with a partner:\n100 wall-ball shots"))

      assert result.partial?
      assert_includes result.reason, 'partner/team'
      assert_nil result.workout.team_size
    end

    test 'a genuinely uncatalogued movement is flagged rather than auto-created' do
      assert_no_difference('Movement.count') do
        result = WorkoutParser.call(page_for_text("For time:\n20 gorilla crawls"))

        assert result.failed?
        assert_includes result.reason, 'gorilla crawls'
      end
    end

    test 'a named Hero WOD with the scoring cue on a later paragraph still detects for-time and rounds, without creating a movement for the title' do
      text = "Ned\n\n7 rounds for time of:\n3 forward rolls\n5 wall walks\n9 box jumps"

      assert_no_difference('Movement.count') do
        result = WorkoutParser.call(page_for_text(text))

        assert_equal 'time', result.workout.score_type
        assert_equal 7, result.workout.rounds
        assert_includes result.reason, 'Ned'
        names = result.workout.exercises.map { |exercise| exercise.movement.name }
        assert_equal ['Forward Roll', 'Wall Walk', 'Box Jump'], names
      end
    end

    test 'a movement-name-first rep scheme line parses the movement with the per-set rep count' do
      result = WorkoutParser.call(page_for_text('Deadlift 5-5-5-5-5 reps'))

      assert result.parsed?
      workout = result.workout
      assert_equal 5, workout.rounds
      deadlift = workout.exercises.find { |exercise| exercise.movement.name == 'Deadlift' }
      assert_equal 5, deadlift.reps
    end

    test 'a bare "movement calories" line (no "for") is recognized as calorie-scored' do
      text = "30-20-10 reps for time of:\nBike calories\nFront-rack reverse lunges\nKnees-to-elbows"

      result = WorkoutParser.call(page_for_text(text))

      bike = result.workout.exercises.find { |exercise| exercise.movement.name == 'Bike' }
      assert_equal 0, bike.calories
    end
  end
end
