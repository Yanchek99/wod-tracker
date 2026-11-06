require 'test_helper'

class SugarwodImport
  class MaxRepDetectorTest < ActiveSupport::TestCase
    test 'builds a rep-scored workout from "Max Unbroken <movement>"' do
      row = { title: 'Max Pull-ups', description: 'Max Unbroken Pull Up', barbell_lift: nil }

      workout = MaxRepDetector.call(row)

      assert_equal 'rep', workout.score_type
      exercise = workout.segments.sole.exercises.sole
      assert_equal movements(:pullup), exercise.movement
    end

    test 'builds a rep-scored workout from "Max <movement>"' do
      row = { title: 'Max Push-ups', description: 'Max Push Up', barbell_lift: nil }

      workout = MaxRepDetector.call(row)

      exercise = workout.segments.sole.exercises.sole
      assert_equal movements(:pushup), exercise.movement
    end

    test 'builds a rep-scored workout from "<movement> (max reps)"' do
      row = { title: 'Max HSPU', description: 'Handstand Push Up (max reps)', barbell_lift: nil }

      workout = MaxRepDetector.call(row)

      exercise = workout.segments.sole.exercises.sole
      assert_equal movements(:hspu), exercise.movement
    end

    test 'builds a rep-scored workout from "<movement>: Max Reps"' do
      row = { title: 'Handstand Push-ups (Strict): Max Reps', description: 'Handstand Push-ups (Strict): Max Reps',
              barbell_lift: nil }

      workout = MaxRepDetector.call(row)

      exercise = workout.segments.sole.exercises.sole
      assert_equal movements(:handstand_push_up), exercise.movement
    end

    test 'builds a rep-scored workout for a weightlifting-family movement with a fixed implement' do
      # Not a fixture: Wall-ball Shot is created dynamically here (and in
      # test/helpers/measurable_helper_test.rb) to avoid colliding with a permanent global
      # movement fixture of the same name.
      wall_ball_shot = Movement.find_or_create_by(name: 'Wall-ball Shot')
      row = { title: 'Max Wallballs', description: 'Max Wallballs', barbell_lift: nil }

      workout = MaxRepDetector.call(row)

      exercise = workout.segments.sole.exercises.sole
      assert_equal wall_ball_shot, exercise.movement
    end

    test 'builds a rep-scored workout for a barbell movement, recording only reps, never a load' do
      row = { title: 'Max Shoulder Press', description: 'Max Shoulder Press', barbell_lift: nil }

      workout = MaxRepDetector.call(row)

      assert_equal 'rep', workout.score_type
      exercise = workout.segments.sole.exercises.sole
      assert_equal movements(:shoulder_press), exercise.movement
    end

    test 'returns nil when more than one movement is mentioned' do
      row = { title: 'Max Combo', description: 'Max Pull Up then Max Push Up', barbell_lift: nil }

      assert_nil MaxRepDetector.call(row)
    end

    test 'returns nil for a monostructural movement, which is scored in calories/distance, not reps' do
      row = { title: 'Max Row', description: 'Max Calorie Row', barbell_lift: nil }

      assert_nil MaxRepDetector.call(row)
    end

    test 'returns nil for a description with no max-effort language' do
      row = { title: 'Pull-up practice', description: '5 sets of 5 Pull Up', barbell_lift: nil }

      assert_nil MaxRepDetector.call(row)
    end
  end
end
