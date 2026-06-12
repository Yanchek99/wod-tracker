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
    assert_no_difference('Metric.where(measurable_type: "Workout").count') do
      assert_difference(['Workout.count', 'ActionText::RichText.count']) do
        post workouts_url, params: { workout: {
          name: @workout.name,
          rounds: @workout.rounds,
          notes: '<div>Use the prescribed loading.</div>',
          score_type: :round
        } }
      end
    end

    assert_redirected_to workout_url(Workout.last)
    assert_equal 'round', Workout.last.score_type
    assert_equal 'Use the prescribed loading.', Workout.last.notes.to_plain_text.strip
  end

  test 'should create workout with nested exercise metrics' do
    assert_difference('Metric.count', 1) do
      assert_difference(['Workout.count', 'Exercise.count'], 1) do
        post workouts_url, params: { workout: {
          name: 'Nested Workout',
          score_type: :time,
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

  test 'should create workout with nested sex-specific exercise metrics' do
    assert_difference('Metric.count', 2) do
      assert_difference(['Workout.count', 'Exercise.count'], 1) do
        post workouts_url, params: { workout: {
          name: 'Sex Specific Workout',
          score_type: :time,
          exercises_attributes: {
            '0' => {
              movement_id: movements(:thruster).id,
              position: 1,
              metrics_attributes: {
                '0' => { measurement: :rep, value: 1 },
                '1' => { measurement: :lb, female_value: 65, male_value: 95 }
              }
            }
          }
        } }
      end
    end

    load_metric = Workout.last.exercises.first.metrics.find_by!(measurement: :lb)
    assert_nil load_metric.value
    assert_equal 65, load_metric.female_value
    assert_equal 95, load_metric.male_value
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
