require 'test_helper'

class SugarwodImport
  class MonostructuralDetectorTest < ActiveSupport::TestCase
    test 'builds a fixed-distance-for-time workout from a meter distance' do
      row = { title: '2K ROW', description: 'For Time: 2,000 Meter Row', barbell_lift: nil }

      workout = MonostructuralDetector.call(row)

      assert_equal 'time', workout.score_type
      exercise = workout.segments.sole.exercises.sole
      assert_equal movements(:row), exercise.movement
      assert_equal 2000, exercise.distance
      assert_equal 'meter', exercise.distance_unit
    end

    test 'builds a fixed-distance-for-time workout from a "5k" shorthand' do
      row = { title: '5K Run', description: 'For Time: 5k Run', barbell_lift: nil }

      workout = MonostructuralDetector.call(row)

      exercise = workout.segments.sole.exercises.sole
      assert_equal movements(:run), exercise.movement
      assert_equal 5000, exercise.distance
      assert_equal 'meter', exercise.distance_unit
    end

    test 'builds a fixed-time-for-max-calories workout' do
      row = { title: 'Max Cal Row', description: '12 Minute Max Calorie Row', barbell_lift: nil }

      workout = MonostructuralDetector.call(row)

      assert_equal 'calorie', workout.score_type
      exercise = workout.segments.sole.exercises.sole
      assert_equal movements(:row), exercise.movement
      assert_equal 720, exercise.duration_seconds
    end

    test 'returns nil when more than one movement is mentioned' do
      row = { title: 'Row Run', description: 'For Time: 500 Meter Row then 400 Meter Run', barbell_lift: nil }

      assert_nil MonostructuralDetector.call(row)
    end

    test 'returns nil when the movement is not monostructural' do
      row = { title: 'Squats for time', description: 'For Time: 50 Air Squats', barbell_lift: nil }

      assert_nil MonostructuralDetector.call(row)
    end

    test 'returns nil for a description that does not match either narrow shape' do
      row = { title: 'Intervals', description: '5 rounds: 250 Meter Row, rest 2:00 between rounds', barbell_lift: nil }

      assert_nil MonostructuralDetector.call(row)
    end

    test 'returns nil for a multi-movement chipper that merely mentions a distance and a monostructural movement' do
      row = { title: 'Born to Run',
              description: 'For Time: 400 Meter Run, 21 Burpees400 Meter Run, 15 Burpees400 Meter Run, ' \
                            '9 Burpees200 Meter Run, 9 Power Cleans (115/85)200 Meter Run, 15 Power Cleans ' \
                            '(115/85)200 Meter Run, 21 Power Cleans (115/85)',
              barbell_lift: nil }

      assert_nil MonostructuralDetector.call(row)
    end

    test 'builds a workout when a real trailing score annotation follows the distance shape' do
      row = { title: '2K Row', description: 'For Time: 2,000 Meter Row*Score = Time it takes to complete the workout',
              barbell_lift: nil }

      workout = MonostructuralDetector.call(row)

      assert_equal 'time', workout.score_type
      exercise = workout.segments.sole.exercises.sole
      assert_equal movements(:row), exercise.movement
      assert_equal 2000, exercise.distance
      assert_equal 'meter', exercise.distance_unit
    end
  end
end
