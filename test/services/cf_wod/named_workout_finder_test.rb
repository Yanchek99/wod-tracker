require 'test_helper'

module CfWod
  class NamedWorkoutFinderTest < ActiveSupport::TestCase
    test 'finds an existing workout named on its own opening paragraph, case-insensitively' do
      body_text = "fran\n\n21-15-9 reps for time of\nThrusters\nPull-ups"

      assert_equal workouts(:fran), NamedWorkoutFinder.find(body_text)
    end

    test 'returns nil when the opening paragraph does not match any workout name' do
      body_text = "For time:\n21 thrusters\n15 pull-ups"

      assert_nil NamedWorkoutFinder.find(body_text)
    end

    test 'returns nil when the opening paragraph is the prescription itself, not a name' do
      body_text = "21-15-9 reps for time of\nThrusters\nPull-ups"

      assert_nil NamedWorkoutFinder.find(body_text)
    end
  end
end
