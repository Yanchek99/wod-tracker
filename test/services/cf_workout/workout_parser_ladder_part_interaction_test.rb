require 'test_helper'

module CfWorkout
  class WorkoutParserLadderPartInteractionTest < ActiveSupport::TestCase
    def workout_page(slug:, body_text:)
      WorkoutPage.new(date: nil, slug: slug, title: nil, body_html: nil, body_text: body_text, description: nil,
                      scaling: nil, rest_day: false, previous_slug: nil, next_slug: nil)
    end

    test 'raises UnparseableError for a segment-wrapped Etc.-terminated ladder' do
      page = workout_page(
        slug: '300111',
        body_text: "Complete as many reps as possible in 10 minutes of:\n" \
                   "0:00-10:00:\n" \
                   "3 burpees\n3 deadlifts\n" \
                   "6 burpees\n6 deadlifts\n" \
                   'Etc.'
      )

      assert_raises(WorkoutParser::UnparseableError) { WorkoutParser.call(page) }
    end

    test 'raises UnparseableError for a multi-part body ending in Etc.' do
      page = workout_page(
        slug: '300112',
        body_text: "Complete as many reps as possible in 10 minutes of:\n" \
                   "200-meter run\n" \
                   "Then, 3 burpees\n3 deadlifts\n" \
                   "6 burpees\n6 deadlifts\n" \
                   'Etc.'
      )

      assert_raises(WorkoutParser::UnparseableError) { WorkoutParser.call(page) }
    end
  end
end
