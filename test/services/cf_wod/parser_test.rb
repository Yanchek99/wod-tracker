require 'test_helper'

module CfWod
  class ParserTest < ActiveSupport::TestCase
    FIXTURES = Rails.root.join('test/fixtures/cf_wod')

    # Not in test/fixtures/movements.yml: their names are substrings of other fixtures ("Row",
    # "Thruster"), which makes system tests elsewhere that select a movement by dropdown text
    # ambiguous. Created here instead, scoped to this file's per-test transactions.
    setup do
      Movement.find_or_create_by!(name: 'Bent-over Row')
      Movement.find_or_create_by!(name: 'Squat Clean Thruster')
    end

    def page_for_fixture(name, date)
      PageParser.new(date, File.read(FIXTURES.join(name))).parse
    end

    test 'legacy AMRAP fixture parses with round-scored format, exact movements, and a flagged unattached load' do
      page = page_for_fixture('legacy_with_scaling.html', Date.new(2018, 1, 10))
      result = WorkoutParser.call(page)

      assert result.partial?
      assert_includes result.reason, 'Male/female load could not be confidently attached'
      workout = result.workout
      assert_equal 'round', workout.score_type
      assert_equal 10, workout.time
      names = workout.exercises.map { |exercise| exercise.movement.name }
      assert_equal ['Power Snatch', 'Overhead Walking Lunge', 'Rope Climb'], names
      assert_equal [5, 10, 1], workout.exercises.map(&:reps)
    end

    test 'modern multi-part (sled drag) fixture builds the main exercise and an event-triggered penalty segment' do
      page = page_for_fixture('modern_multi_part.html', Date.new(2026, 6, 20))
      result = WorkoutParser.call(page)

      assert result.partial?
      assert_includes result.reason, 'Event-triggered penalty segment'
      workout = result.workout
      assert_equal 'time', workout.score_type
      sled_drag = workout.exercises.find { |exercise| exercise.movement.name == 'Sled Drag' }
      assert_equal 1600, sled_drag.distance
      assert_equal 'meter', sled_drag.distance_unit

      penalty = workout.segments.first
      assert_equal 'Any time you stop', penalty.name
      assert_equal 'Bent-over Row', penalty.exercises.first.movement.name
      assert_equal 15, penalty.exercises.first.reps
    end

    test 'modern windowed-clock fixture (250618) builds timed segments despite no workout-level score type' do
      page = page_for_fixture('modern_normal.html', Date.new(2025, 6, 18))
      result = WorkoutParser.call(page)

      assert result.partial?
      assert_includes result.reason, 'Could not determine workout format from body text'
      assert_includes result.reason, 'Could not match movement: "Echo bike"'
      workout = result.workout
      assert_nil workout.score_type
      assert_equal 4, workout.segments.size
      assert(workout.segments.all? { |segment| segment.time_seconds == 120 })
      assert_equal 'Front Squat', workout.segments.first.exercises.first.movement.name
      # "Echo Bike" isn't in the Movement catalog (a brand-specific machine name), so it's
      # unmatched and dropped rather than auto-created -- only Front Squat and Rest remain.
      names = workout.segments.first.exercises.map { |exercise| exercise.movement.name }
      assert_equal ['Front Squat', 'Rest'], names
    end

    test 'rest day fixture fails immediately without attempting to parse' do
      page = page_for_fixture('modern_rest_day.html', Date.new(2026, 7, 2))
      result = WorkoutParser.call(page)

      assert result.failed?
      assert_nil result.workout
      assert_includes result.reason, 'Rest day'
    end
  end
end
