require 'test_helper'

class WorkoutMergeTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup { sign_in users(:mathew) }

  test 'updating a workout into an existing one merges and redirects to it' do
    canonical = Workout.create!(name: 'Canon', score_type: :time) do |w|
      w.exercises.build(movement: movements(:pullup), position: 1, reps: 5)
    end
    other = Workout.create!(name: 'Other', score_type: :time) do |w|
      w.exercises.build(movement: movements(:pushup), position: 1, reps: 5)
    end

    patch workout_url(other), params: { workout: {
      exercises_attributes: [{ id: other.exercises.first.id, movement_id: movements(:pullup).id, position: 1, reps: 5 }]
    } }

    assert_redirected_to workout_url(canonical)
    assert_not Workout.exists?(other.id)
  end
end
