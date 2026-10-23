require 'test_helper'

class ProgramSchedulesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:mathew)
    sign_in @user
    @program = Program.create!(name: 'Mine')
    @program.subscriptions.create!(user: @user, role: :owner)
  end

  test 'owner sees the Schedule workout form with a workout select and a date' do
    get new_program_schedule_url(@program)

    assert_response :success
    assert_select 'form[action=?]', program_schedules_path(@program)
    assert_select 'select[name="schedule[workout_id]"] option', text: 'Fran'
    assert_select 'input[type=date][name="schedule[posted_on]"]'
    assert_select 'a[href=?]', program_path(@program), text: 'Cancel'
  end

  test 'coach can schedule too' do
    coached = Program.create!(name: 'Coached')
    coached.subscriptions.create!(user: @user, role: :coach)

    get new_program_schedule_url(coached)

    assert_response :success
  end

  test 'an athlete cannot open the form' do
    assert_raises(CanCan::AccessDenied) { get new_program_schedule_url(programs(:crossfit)) }
  end

  test 'creating schedules the workout at 6pm Pacific on the chosen date and returns to the program' do
    assert_difference -> { @program.schedules.count }, 1 do
      post program_schedules_url(@program), params: { schedule: { workout_id: workouts(:fran).id, posted_on: '2026-08-10' } }
    end

    assert_redirected_to program_url(@program)
    schedule = @program.schedules.order(:id).last

    assert_equal workouts(:fran), schedule.workout
    assert_equal ActiveSupport::TimeZone['America/Los_Angeles'].local(2026, 8, 10, 18), schedule.posted_at
  end

  test 'a missing workout re-renders the form with a 422' do
    assert_no_difference -> { Schedule.count } do
      post program_schedules_url(@program), params: { schedule: { workout_id: '', posted_on: '2026-08-10' } }
    end

    assert_response :unprocessable_content
    assert_select 'form[action=?]', program_schedules_path(@program)
  end

  test 'a missing date re-renders the form with a 422' do
    post program_schedules_url(@program), params: { schedule: { workout_id: workouts(:fran).id, posted_on: '' } }

    assert_response :unprocessable_content
  end

  test 'an athlete cannot create' do
    assert_raises(CanCan::AccessDenied) do
      post program_schedules_url(programs(:crossfit)), params: { schedule: { workout_id: workouts(:fran).id, posted_on: '2026-08-10' } }
    end
  end
end
