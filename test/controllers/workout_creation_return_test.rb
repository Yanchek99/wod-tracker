require 'test_helper'

class WorkoutCreationReturnTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:mathew)
    sign_in @user
    @program = Program.create!(name: 'Mine')
    @program.subscriptions.create!(user: @user, role: :owner)
  end

  test 'creating a workout from the Schedule workout flow returns to the form with it selected' do
    post workouts_url, params: { schedule_program_id: @program.id, workout: { name: 'Return Flow', score_type: :time } }

    workout = Workout.find_by!(name: 'Return Flow')

    assert_redirected_to new_program_schedule_url(@program, workout_id: workout.id)
  end

  test 'a program the user cannot schedule on is ignored and the workout page is shown' do
    post workouts_url, params: { schedule_program_id: programs(:crossfit).id, workout: { name: 'No Return', score_type: :time } }

    assert_redirected_to workout_url(Workout.find_by!(name: 'No Return'))
  end

  test 'without the parameter creating a workout still shows the workout' do
    post workouts_url, params: { workout: { name: 'Plain', score_type: :time } }

    assert_redirected_to workout_url(Workout.find_by!(name: 'Plain'))
  end

  test 'the new workout form carries the program through to create' do
    get new_workout_url(schedule_program_id: @program.id)

    assert_select 'form.workout-form input[type=hidden][name=schedule_program_id][value=?]', @program.id.to_s
    assert_select 'a[href=?]', new_unstructured_workouts_path(schedule_program_id: @program.id)
  end

  test 'the paste-text form carries the program through to extract' do
    get new_unstructured_workouts_url(schedule_program_id: @program.id)

    assert_select 'form[action=?] input[type=hidden][name=schedule_program_id][value=?]', extract_workouts_path, @program.id.to_s
  end

  test 'no hidden field without the parameter' do
    get new_workout_url

    assert_select 'input[name=schedule_program_id]', count: 0
  end
end
