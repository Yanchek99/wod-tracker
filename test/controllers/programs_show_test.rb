require 'test_helper'

class ProgramsShowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:mathew)
    sign_in @user
  end

  test 'athlete sees the header, a Following button, and Log buttons but no management controls' do
    get program_url(programs(:crossfit))

    assert_response :success
    assert_select 'h1.program-title', text: 'Crossfit'
    assert_select '.program-header .role-pill--athlete', text: 'Athlete'
    assert_select '.program-header form[action=?][data-turbo-confirm*="Unfollow Crossfit?"]', unsubscribe_program_path(programs(:crossfit))
    assert_select '.program-header form[action=?]', program_path(programs(:crossfit)), count: 0
    assert_select '.schedule-card a.schedule-log'
    assert_select '.schedule-workout-panel', count: 0
  end

  test 'the Log workout button sits inside the workout card at every width, not under it' do
    get program_url(programs(:crossfit))

    assert_select '.workout-card a.schedule-log:not(.d-md-none)', minimum: 1
    assert_select '.schedule-log-desktop', count: 0
  end

  test 'owner sees Delete with a confirm that spells out what goes, and the Schedule workout panel' do
    program = owned_program('Mine')
    schedule_on(program, workouts(:fran), 2.days.ago)

    get program_url(program)

    assert_select '.program-header .role-pill--owner', text: 'Owner'
    assert_select '.program-header form[action=?][data-turbo-confirm*="1 scheduled workout"]', program_path(program)
    assert_select '.program-header form[action=?]', unsubscribe_program_path(program), count: 0
    assert_select '.schedule-workout-panel[href=?]', new_program_schedule_path(program), text: /Schedule workout/
  end

  test 'coach can unfollow, cannot delete, and can schedule workouts' do
    program = Program.create!(name: 'Coached')
    program.subscriptions.create!(user: @user, role: :coach)

    get program_url(program)

    assert_select '.program-header .role-pill--coach'
    assert_select '.program-header form[action=?]', unsubscribe_program_path(program)
    assert_select '.program-header form[action=?]', program_path(program), count: 0
    assert_select '.schedule-workout-panel'
  end

  test 'a non-follower sees Follow, no pill, no Log buttons and no Schedule workout panel' do
    get program_url(programs(:local_gym))

    assert_select '.program-header form[action=?]', subscribe_program_path(programs(:local_gym))
    assert_select '.program-header .role-pill', count: 0
    assert_select 'a.schedule-log', count: 0
    assert_select '.schedule-workout-panel', count: 0
  end

  test 'an admin who is not the owner can delete and still gets the normal Follow control' do
    users(:brooke).update!(role: :admin)
    sign_in users(:brooke)

    get program_url(programs(:crossfit))

    assert_select '.program-header form[action=?]', program_path(programs(:crossfit))
    assert_select '.program-header form[action=?]', subscribe_program_path(programs(:crossfit))
  end

  test 'only workouts dated today or earlier are listed' do
    program = owned_program('Dated')
    schedule_on(program, workouts(:fran), 2.days.ago)
    schedule_on(program, workouts(:murph), 3.days.from_now)

    get program_url(program)

    assert_select '.schedule-card', count: 1
    assert_select '.workout-name', text: 'Fran'
    assert_select '.workout-name', text: 'Murph', count: 0
  end

  test 'a workout scheduled for today shows before its 6pm Pacific anchor, tomorrows still does not' do
    zone = SchedulesController::POSTED_AT_ZONE
    program = owned_program('Today')

    travel_to zone.local(2026, 8, 10, 10) do
      schedule_on(program, workouts(:fran), zone.local(2026, 8, 10, 18))
      schedule_on(program, workouts(:murph), zone.local(2026, 8, 11, 18))

      get program_url(program)

      assert_select '.schedule-card', count: 1
      assert_select '.workout-name', text: 'Fran'
    end
  end

  test 'workout cards omit the program name and group under date headings' do
    program = owned_program('Grouped')
    schedule_on(program, workouts(:fran), 2.days.ago)

    get program_url(program)

    assert_select '.workout-program', count: 0
    assert_select '.program-date', count: 1
  end

  test 'shows a message when no workouts have been posted' do
    program = owned_program('Empty')

    get program_url(program)

    assert_select '.empty-note', text: /No workouts posted yet/
    assert_select '.empty-state', count: 0
  end

  private

  def owned_program(name)
    Program.create!(name: name).tap { |program| program.subscriptions.create!(user: @user, role: :owner) }
  end

  def schedule_on(program, workout, posted_at)
    Schedule.create!(program: program, workout: workout, posted_at: posted_at)
  end
end
