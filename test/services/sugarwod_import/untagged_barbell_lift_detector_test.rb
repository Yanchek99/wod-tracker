require 'test_helper'

class SugarwodImport
  class UntaggedBarbellLiftDetectorTest < ActiveSupport::TestCase
    test 'returns nil when barbell_lift is already present' do
      row = { barbell_lift: 'Back Squat', title: 'Back Squat', description: '5 Sets of 5', set_details: '[]' }

      assert_nil UntaggedBarbellLiftDetector.call(row)
    end

    test 'builds a workout from an unambiguous single movement in the description, regardless of a generic title' do
      row = { barbell_lift: '', title: 'Skill Work',
              description: 'Pre-workout: Build to a heavy set of 3 power snatches - Touch and go reps.',
              set_details: '[{"success":true,"load":95},{"success":true,"load":115},{"success":true,"load":135}]' }

      workout = UntaggedBarbellLiftDetector.call(row)

      assert_equal movements(:power_snatch), workout.segments.sole.exercises.first.movement
    end

    test 'builds a workout from a bare movement title when the description has no movement words at all' do
      row = { barbell_lift: '', title: 'Back Squat', description: 'For Total Load: 5 Sets of 5',
              set_details: '[{"success":true,"load":225}]' }

      workout = UntaggedBarbellLiftDetector.call(row)

      assert_equal movements(:back_squat), workout.segments.sole.exercises.first.movement
    end

    test 'returns nil for a complex-in-disguise where the description names multiple movements' do
      row = { barbell_lift: '', title: 'Clean Pulls',
              description: '5 Sets:1 Clean Deadlift2 Hang Clean Pulls:5s Pause at Hang (Knee Level)1 Hang Clean Pull',
              set_details: '[{"success":true,"load":225}]' }

      assert_nil UntaggedBarbellLiftDetector.call(row)
    end

    test 'returns nil when the title and description name conflicting movements' do
      row = { barbell_lift: '', title: 'Back Squat', description: '5 Sets: 3 Front Squats',
              set_details: '[{"success":true,"load":225}]' }

      assert_nil UntaggedBarbellLiftDetector.call(row)
    end

    test 'returns nil when neither the title nor the description names exactly one movement' do
      row = { barbell_lift: '', title: 'Skill Work', description: 'Pre-workout: some assistance work',
              set_details: '[{"success":true,"load":95}]' }

      assert_nil UntaggedBarbellLiftDetector.call(row)
    end
  end
end
