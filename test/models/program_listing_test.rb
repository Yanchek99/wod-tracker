require 'test_helper'

class ProgramListingTest < ActiveSupport::TestCase
  setup do
    @user = users(:mathew)
    @zone = ActiveSupport::TimeZone['America/Los_Angeles']
  end

  test 'lists followed programs first, then the rest, each alphabetical' do
    zebra = Program.create!(name: 'Zebra')
    zebra.subscriptions.create!(user: @user, role: :owner)
    Program.create!(name: 'Alpha')

    names = ProgramListing.for(@user).map { |row| row.program.name }

    assert_equal ['Crossfit', 'Zebra', 'Alpha', 'Local Gym'], names
  end

  test 'counts followers and scheduled workouts per program' do
    program = programs(:crossfit)
    program.subscriptions.create!(user: users(:brooke), role: :athlete)
    already_scheduled = program.schedules.count
    schedule(program, workouts(:fran), 2.days.ago)
    schedule(program, workouts(:murph), 1.day.ago)

    row = row_for(program)

    assert_equal 2, row.followers
    assert_equal already_scheduled + 2, row.workouts
  end

  test 'latest posted ignores future schedules' do
    program = programs(:crossfit)
    past = schedule(program, workouts(:fran), 3.days.ago)
    schedule(program, workouts(:murph), 3.days.from_now)

    assert_equal past.posted_at.to_i, row_for(program).latest_posted_at.to_i
  end

  test 'latest posted counts a workout scheduled for today before its 6pm Pacific anchor' do
    zone = ActiveSupport::TimeZone['America/Los_Angeles']
    program = programs(:crossfit)

    travel_to zone.local(2026, 8, 10, 10) do
      today = schedule(program, workouts(:murph), zone.local(2026, 8, 10, 18))
      schedule(program, workouts(:fran), zone.local(2026, 8, 11, 18))

      assert_equal today.posted_at.to_i, row_for(program).latest_posted_at.to_i
    end
  end

  test 'role is the users role, nil when not following' do
    assert_equal 'athlete', row_for(programs(:crossfit)).role
    assert_nil row_for(programs(:local_gym)).role
  end

  test 'query count does not grow with the number of programs' do
    small = count_queries { ProgramListing.for(@user) }
    6.times { |i| Program.create!(name: "Extra #{i}").subscriptions.create!(user: @user, role: :athlete) }
    large = count_queries { ProgramListing.for(@user) }

    assert_equal small, large
  end

  test 'program names must be present' do
    assert_not Program.new(name: '').valid?
    assert_not Program.new(name: nil).valid?
  end

  private

  def row_for(program)
    ProgramListing.for(@user).find { |row| row.program == program }
  end

  def schedule(program, workout, posted_at)
    Schedule.create!(program: program, workout: workout, posted_at: posted_at)
  end

  def count_queries(&)
    ActiveRecord::Base.connection.clear_query_cache
    count = 0
    counter = ->(*, payload) { count += 1 unless payload[:cached] || payload[:name] == 'SCHEMA' }
    ActiveSupport::Notifications.subscribed(counter, 'sql.active_record', &)
    count
  end
end
