require 'test_helper'

module CfWod
  class ParserTrailingDistanceTest < ActiveSupport::TestCase
    # Not in test/fixtures/movements.yml -- created here, scoped to this file's per-test transactions.
    setup do
      Movement.find_or_create_by!(name: 'Hang Squat Clean')
    end

    def page_for_text(body_text)
      WodPage.new(date: Date.current, slug: 'x', title: 'x', body_html: body_text, body_text: body_text,
                  description: nil, scaling: nil, rest_day: false, previous_slug: nil, next_slug: nil)
    end

    test 'a trailing "to N feet" clause on a movement line is parsed as the rope climb height, not left attached to the movement name' do
      text = "For time:\n15 hang squat cleans\n5 rope climbs to 15 feet\n12 hang squat cleans\n4 rope climbs\n" \
             "9 hang squat cleans\n3 rope climbs\n\nPost time to comments.\n\n♀ 105-lb barbell\n♂ 155-lb barbell"

      result = Parser.call(page_for_text(text))

      assert result.partial?
      assert_includes result.reason, 'Male/female load could not be confidently attached'
      names = result.workout.exercises.map { |exercise| exercise.movement.name }
      assert_equal ['Hang Squat Clean', 'Rope Climb', 'Hang Squat Clean', 'Rope Climb', 'Hang Squat Clean', 'Rope Climb'], names
      first_rope_climb = result.workout.exercises.find { |exercise| exercise.movement.name == 'Rope Climb' }
      assert_equal 15, first_rope_climb.distance
      assert_equal 'foot', first_rope_climb.distance_unit
    end
  end
end
