require 'test_helper'

class WorkoutPositionUpdatesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:mathew)
  end

  test 'updates existing exercise positions' do
    workout = workouts(:murph)

    patch workout_url(workout), params: { workout: {
      name: workout.name,
      rounds: workout.rounds,
      score_type: workout.score_type,
      exercises_attributes: {
        '0' => exercise_position_params(exercises(:murph_run), 2),
        '1' => exercise_position_params(exercises(:murph_pullup), 1),
        '2' => exercise_position_params(exercises(:murph_pushup), 3),
        '3' => exercise_position_params(exercises(:murph_squat), 4),
        '4' => exercise_position_params(exercises(:murph_second_run), 5)
      }
    } }

    assert_redirected_to workout_url(workout)
    assert_equal [exercises(:murph_pullup), exercises(:murph_run), exercises(:murph_pushup),
                  exercises(:murph_squat), exercises(:murph_second_run)], workout.reload.ordered_parts
  end

  private

  def exercise_position_params(exercise, position)
    {
      id: exercise.id,
      movement_id: exercise.movement_id,
      position:
    }
  end
end
