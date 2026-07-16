require 'test_helper'

class WorkoutMergeTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup { sign_in users(:mathew) }

  test 'updating a workout into an existing one merges and redirects to it' do
    canonical = Workout.create!(name: 'Canon', score_type: :time)
    canonical.segments.create!(position: 1).exercises.create!(movement: movements(:pullup), position: 1, reps: 5)
    other = Workout.create!(name: 'Other', score_type: :time)
    other_segment = other.segments.create!(position: 1)
    other_segment.exercises.create!(movement: movements(:pushup), position: 1, reps: 5)

    patch workout_url(other), params: { workout: {
      segments_attributes: {
        '0' => {
          id: other_segment.id,
          position: 1,
          exercises_attributes: {
            '0' => { id: other_segment.exercises.first.id, movement_id: movements(:pullup).id, position: 1, reps: 5 }
          }
        }
      }
    } }

    assert_redirected_to workout_url(canonical)
    assert_not Workout.exists?(other.id)
  end
end
