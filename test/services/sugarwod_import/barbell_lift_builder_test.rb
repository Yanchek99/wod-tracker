require 'test_helper'

class SugarwodImport
  class BarbellLiftBuilderTest < ActiveSupport::TestCase
    test 'builds one segment with N exercises for a varying pyramid scheme' do
      row = { title: 'Front Squat 3-1-3-1-3-1-12', description: '', barbell_lift: 'Front Squat',
              set_details: '[{"success":true,"load":155},{"success":true,"load":165},{"success":true,"load":155},' \
                           '{"success":true,"load":175},{"success":true,"load":155},{"success":true,"load":185},' \
                           '{"success":true,"load":125}]' }

      workout = BarbellLiftBuilder.call(row)

      assert_equal 'weight', workout.score_type
      segment = workout.segments.sole
      assert_nil segment.rounds
      assert_nil segment.time_seconds
      exercises = segment.exercises
      assert_equal 7, exercises.size
      assert_equal [3, 1, 3, 1, 3, 1, 12], exercises.map(&:reps)
      assert(exercises.all? { |exercise| exercise.movement == movements(:front_squat) })
      assert(exercises.all? { |exercise| exercise.load.nil? })
    end

    test 'builds a single exercise for a simple heavy-single lift' do
      row = { title: 'Deadlift', description: 'Build to a heavy deadlift for the day', barbell_lift: 'Deadlift',
              set_details: '[{"success":true,"load":315}]' }

      workout = BarbellLiftBuilder.call(row)

      exercise = workout.segments.sole.exercises.sole
      assert_equal 1, exercise.reps
      assert_equal movements(:deadlift), exercise.movement
    end

    test 'returns nil when barbell_lift is blank' do
      row = { title: 'Deadlift', description: '', barbell_lift: '', set_details: '[{"success":true,"load":315}]' }

      assert_nil BarbellLiftBuilder.call(row)
    end

    test 'returns nil when the barbell_lift name is not in the movement catalog' do
      row = { title: 'Nonexistent Lift', description: '', barbell_lift: 'Nonexistent Lift',
              set_details: '[{"success":true,"load":100}]' }

      assert_nil BarbellLiftBuilder.call(row)
    end

    test 'returns nil when SetSchemeExtractor cannot resolve the row' do
      row = { title: 'Deadlift', description: 'Build to a heavy deadlift for the day', barbell_lift: 'Deadlift',
              set_details: '[{"success":true,"load":275},{"success":true,"load":315}]' }

      assert_nil BarbellLiftBuilder.call(row)
    end

    test 'builds a workout that can actually be persisted' do
      row = { title: 'Deadlift', description: 'Build to a heavy deadlift for the day', barbell_lift: 'Deadlift',
              set_details: '[{"success":true,"load":315}]' }

      workout = BarbellLiftBuilder.call(row)

      assert workout.valid?, workout.errors.full_messages.join(', ')
      assert_equal 'Deadlift 1', workout.name
    end
  end
end
