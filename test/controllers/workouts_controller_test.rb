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
    assert_difference('Workout.count') do
      post workouts_url, params: { workout: {
        name: @workout.name,
        rounds: @workout.rounds,
        metric_attributes: { measurement: :round }
      } }
    end

    assert_redirected_to workout_url(Workout.last)
  end

  test 'should create workout with nested exercise metrics' do
    assert_difference('Metric.count', 2) do
      assert_difference(['Workout.count', 'Exercise.count'], 1) do
        post workouts_url, params: { workout: {
          name: 'Nested Workout',
          metric_attributes: { measurement: :time },
          exercises_attributes: {
            '0' => {
              movement_id: movements(:pullup).id,
              position: 1,
              metrics_attributes: {
                '0' => { measurement: :rep, value: 10 }
              }
            }
          }
        } }
      end
    end

    assert_redirected_to workout_url(Workout.last)
    assert_equal movements(:pullup), Workout.last.exercises.first.movement
    assert_equal 10, Workout.last.exercises.first.metrics.find_by!(measurement: :rep).value
  end

  test 'should show workout' do
    get workout_url(@workout)
    assert_response :success
  end

  test 'should get edit' do
    get edit_workout_url(@workout)
    assert_response :success
  end

  test 'should update workout' do
    patch workout_url(@workout), params: { workout: { name: @workout.name, rounds: @workout.rounds } }
    assert_redirected_to workout_url(@workout)
  end

  test 'should destroy workout' do
    assert_difference('Workout.count', -1) do
      delete workout_url(@workout)
    end

    assert_redirected_to workouts_url
  end
end
