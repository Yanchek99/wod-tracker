require 'test_helper'

class SugarwodImport
  class MaxDistanceDetectorTest < ActiveSupport::TestCase
    test 'builds a distance-scored workout from "<movement>: Max Height"' do
      # Not a fixture: Box Jump is created dynamically here (and in test/helpers/measurable_helper_test.rb)
      # to avoid colliding with a permanent global movement fixture of the same name.
      box_jump = Movement.find_or_create_by(name: 'Box Jump')
      row = { title: 'Box Jump: Max Height', description: 'Box Jump: Max Height', barbell_lift: nil }

      workout = MaxDistanceDetector.call(row)

      assert_equal 'distance', workout.score_type
      exercise = workout.segments.sole.exercises.sole
      assert_equal box_jump, exercise.movement
    end

    test 'returns nil when barbell_lift is already present' do
      row = { title: 'Box Jump: Max Height', description: 'Box Jump: Max Height', barbell_lift: 'Box Jump' }

      assert_nil MaxDistanceDetector.call(row)
    end

    test 'returns nil for a description with no "Max Height" language' do
      row = { title: 'Box Jump', description: '5 Sets of 5 Box Jumps', barbell_lift: nil }

      assert_nil MaxDistanceDetector.call(row)
    end

    test 'returns nil when the resolved movement is monostructural' do
      row = { title: 'Row: Max Height', description: 'Row: Max Height', barbell_lift: nil }

      assert_nil MaxDistanceDetector.call(row)
    end
  end
end
