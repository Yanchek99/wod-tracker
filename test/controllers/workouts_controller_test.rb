require 'test_helper'

class WorkoutsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @workout = workouts(:fran)
    sign_in users(:mathew)
  end

  test 'should get index' do
    get workouts_url
    assert_response :success
  end

  test 'should get new' do
    get new_workout_url
    assert_response :success
  end

  test 'should create workout' do
    assert_difference(['Workout.count', 'ActionText::RichText.count']) do
      post workouts_url, params: { workout: {
        name: @workout.name,
        rounds: @workout.rounds,
        notes: '<div>Use the prescribed loading.</div>',
        score_type: :round
      } }
    end

    assert_redirected_to workout_url(Workout.last)
    assert_equal 'round', Workout.last.score_type
    assert_equal 'Use the prescribed loading.', Workout.last.notes.to_plain_text.strip
  end

  test 'should create workout with direct exercise prescriptions' do
    assert_difference(['Workout.count', 'Exercise.count'], 1) do
      post workouts_url, params: { workout: {
        name: 'Nested Workout',
        score_type: :time,
        exercises_attributes: {
          '0' => {
            movement_id: movements(:pullup).id,
            position: 1,
            reps: 10
          }
        }
      } }
    end

    assert_redirected_to workout_url(Workout.last)
    exercise = Workout.last.exercises.first
    assert_equal movements(:pullup), exercise.movement
    assert_equal 10, exercise.reps
  end

  test 'should create workout with sex-specific exercise prescriptions' do
    assert_difference(['Workout.count', 'Exercise.count'], 1) do
      post workouts_url, params: { workout: {
        name: 'Sex Specific Workout',
        score_type: :time,
        exercises_attributes: {
          '0' => {
            movement_id: movements(:thruster).id,
            position: 1,
            reps: 1,
            female_load: 65, male_load: 95
          }
        }
      } }
    end

    exercise = Workout.last.exercises.first
    assert_nil exercise.load
    assert_equal 65, exercise.female_load
    assert_equal 95, exercise.male_load
    assert_predicate exercise, :load_bearing?
  end

  test 'should show workout' do
    get workout_url(@workout)
    assert_response :success
  end

  test 'should get edit' do
    get edit_workout_url(@workout)
    assert_response :success
    assert_select 'trix-editor'
  end

  test 'should update workout' do
    patch workout_url(@workout), params: { workout: {
      name: @workout.name,
      rounds: @workout.rounds,
      notes: '<div>Break up the pull-ups early.</div>'
    } }

    assert_redirected_to workout_url(@workout)
    assert_equal 'Break up the pull-ups early.', @workout.reload.notes.to_plain_text.strip
  end

  test 'should destroy workout' do
    assert_difference('Workout.count', -1) do
      delete workout_url(@workout)
    end

    assert_redirected_to workouts_url
  end
end
