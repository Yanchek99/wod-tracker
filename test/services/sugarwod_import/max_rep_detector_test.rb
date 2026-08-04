require 'test_helper'

class SugarwodImport
  class BodyweightMaxRepDetectorTest < ActiveSupport::TestCase
    test 'builds a rep-scored workout from "Max Unbroken <movement>"' do
      row = { title: 'Max Pull-ups', description: 'Max Unbroken Pull Up', barbell_lift: nil }

      workout = BodyweightMaxRepDetector.call(row)

      assert_equal 'rep', workout.score_type
      exercise = workout.segments.sole.exercises.sole
      assert_equal movements(:pullup), exercise.movement
    end

    test 'builds a rep-scored workout from "Max <movement>"' do
      row = { title: 'Max Push-ups', description: 'Max Push Up', barbell_lift: nil }

      workout = BodyweightMaxRepDetector.call(row)

      exercise = workout.segments.sole.exercises.sole
      assert_equal movements(:pushup), exercise.movement
    end

    test 'builds a rep-scored workout from "<movement> (max reps)"' do
      row = { title: 'Max HSPU', description: 'Handstand Push Up (max reps)', barbell_lift: nil }

      workout = BodyweightMaxRepDetector.call(row)

      exercise = workout.segments.sole.exercises.sole
      assert_equal movements(:hspu), exercise.movement
    end

    test 'returns nil when more than one movement is mentioned' do
      row = { title: 'Max Combo', description: 'Max Pull Up then Max Push Up', barbell_lift: nil }

      assert_nil BodyweightMaxRepDetector.call(row)
    end

    test 'returns nil when the movement is not gymnastics' do
      row = { title: 'Max Row', description: 'Max Calorie Row', barbell_lift: nil }

      assert_nil BodyweightMaxRepDetector.call(row)
    end

    test 'returns nil for a description with no max-effort language' do
      row = { title: 'Pull-up practice', description: '5 sets of 5 Pull Up', barbell_lift: nil }

      assert_nil BodyweightMaxRepDetector.call(row)
    end
  end
end
