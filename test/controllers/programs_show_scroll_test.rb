require 'test_helper'

class ProgramsShowScrollTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:mathew)
    sign_in @user
  end

  test 'workouts load by infinite scroll: ten first, then a lazy frame for the next page' do
    program = owned_program('Big')
    12.times { |i| schedule_on(program, workouts(:fran), (i + 1).days.ago) }

    get program_url(program)

    assert_select '.schedule-card', count: 10
    assert_select 'ul.pagination', count: 0
    assert_select 'turbo-frame#program_schedules_page_2[loading=lazy][src=?]', program_path(program, page: 2)
  end

  test 'the next-page frame request returns just the remaining cards and no further frame' do
    program = owned_program('Big')
    12.times { |i| schedule_on(program, workouts(:fran), (i + 1).days.ago) }

    get program_url(program, page: 2), headers: { 'Turbo-Frame' => 'program_schedules_page_2' }

    assert_response :success
    assert_select 'turbo-frame#program_schedules_page_2 .schedule-card', count: 2
    assert_select 'turbo-frame[loading=lazy]', count: 0
    assert_select '.program-header', count: 0
  end

  test 'a frame request past the end is empty and shows no empty state' do
    program = owned_program('Big')
    schedule_on(program, workouts(:fran), 1.day.ago)

    get program_url(program, page: 5), headers: { 'Turbo-Frame' => 'program_schedules_page_5' }

    assert_response :success
    assert_select '.schedule-card', count: 0
    assert_select '.empty-state', count: 0
  end

  test 'a day split across a page boundary shows its heading only once' do
    program = owned_program('Split')
    zone = SchedulesController::POSTED_AT_ZONE
    9.times { |i| schedule_on(program, workouts(:fran), zone.local(2026, 3, 20 - i, 18)) }
    schedule_on(program, workouts(:fran), zone.local(2026, 3, 11, 18))
    schedule_on(program, workouts(:murph), zone.local(2026, 3, 11, 17))

    get program_url(program, page: 2), headers: { 'Turbo-Frame' => 'program_schedules_page_2' }

    assert_select '.schedule-card', count: 1
    assert_select '.program-date', count: 0
  end

  private

  def owned_program(name)
    Program.create!(name: name).tap { |program| program.subscriptions.create!(user: @user, role: :owner) }
  end

  def schedule_on(program, workout, posted_at)
    Schedule.create!(program: program, workout: workout, posted_at: posted_at)
  end
end
