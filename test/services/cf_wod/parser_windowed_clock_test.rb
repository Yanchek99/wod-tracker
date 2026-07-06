require 'test_helper'

module CfWod
  class ParserWindowedClockTest < ActiveSupport::TestCase
    # Not in test/fixtures/movements.yml -- created here, scoped to this file's per-test transactions.
    setup do
      Movement.find_or_create_by!(name: 'Freestanding Shoulder Tap')
      Movement.find_or_create_by!(name: 'Skin the Cat')
      Movement.find_or_create_by!(name: 'L Pull-up')
      Movement.find_or_create_by!(name: 'Deficit Push-up')
    end

    def page_for_text(body_text)
      WodPage.new(date: Date.current, slug: 'x', title: 'x', body_html: body_text, body_text: body_text,
                  description: nil, scaling: nil, rest_day: false, previous_slug: nil, next_slug: nil)
    end

    # Real body text fetched from crossfit.com/250622: a 20-minute clock split into four bare
    # time-range headers ("0:00-5:00:"), each holding a run plus a window-specific max-effort
    # movement, scored by total reps.
    def windowed_clock_total_reps_text
      "On a 20-minute clock for total reps:\n\n" \
        "0:00-5:00:\n200-meter run\nMax freestanding shoulder taps\n\n" \
        "5:00-10:00:\n200-meter run\nMax skin-the-cats\n\n" \
        "10:00-15:00:\n200-meter run\nMax L pull-ups\n\n" \
        "15:00-20:00:\n200-meter run\nMax deficit push-ups\n\n" \
        "♀ 2-inch deficit\n♂ 4-inch deficit\n\nPost reps to comments."
    end

    test 'a windowed clock with bare time-range headers builds one AMRAP segment per window, scored by total reps' do
      result = Parser.call(page_for_text(windowed_clock_total_reps_text))
      workout = result.workout

      # The trailing gendered-load block can't attach to a single exercise once it follows a
      # segment (BodyBuilder resets last_single_exercise after each segment) -- expected and
      # out of scope for this fix, so the result stays partial for that reason alone.
      assert result.partial?
      assert_includes result.reason, 'Male/female load could not be confidently attached'
      assert_equal 'rep', workout.score_type
      assert_nil workout.time
      assert_nil workout.rounds
      assert_nil workout.interval
      assert_equal 4, workout.segments.size
      assert(workout.segments.all? { |segment| segment.time_seconds == 300 && segment.amrap? })
      max_movements = workout.segments.map { |segment| segment.exercises.last.movement.name }
      assert_equal ['Freestanding Shoulder Tap', 'Skin the Cat', 'L Pull-up', 'Deficit Push-up'], max_movements
      assert(workout.segments.all? { |segment| segment.exercises.first.movement.name == 'Run' })
      assert(workout.segments.all? { |segment| segment.exercises.last.reps.zero? })
    end
  end
end
