require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'name is first and last names' do
    brooke = users(:brooke)
    assert_equal "#{brooke.first_name} #{brooke.last_name}", brooke.name
  end

  test 'defaults to imperial units and shows loads in pounds' do
    assert_predicate users(:brooke), :unit_system_imperial?
    assert_equal :lb, users(:brooke).load_display_unit
  end

  test 'a metric athlete shows loads in kilograms' do
    brooke = users(:brooke)
    brooke.update!(unit_system: :metric)

    assert_equal :kg, brooke.load_display_unit
  end

  test 'personal_records keeps the heaviest load within the same rep count, regardless of log order' do
    deadlift = movements(:deadlift)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: deadlift, load: 225, reps: 5)
    log.movement_logs.create!(movement: deadlift, load: 275, reps: 5)

    records = users(:mathew).personal_records.select { |pr| pr.movement == deadlift }

    assert_equal [275], records.map(&:load)
  end

  test 'personal_records shows a separate record per rep count for the same movement' do
    deadlift = movements(:deadlift)
    log = logs(:matt_amrap)
    log.movement_logs.create!(movement: deadlift, load: 275, reps: 5)
    log.movement_logs.create!(movement: deadlift, load: 185, reps: 52)

    records = users(:mathew).personal_records.select { |pr| pr.movement == deadlift }

    assert_equal [[185, 52], [275, 5]], records.map { |pr| [pr.load, pr.reps] }.sort
  end

  test 'workout_records keeps the lowest score for a time-scored workout' do
    workout = workouts(:fran)
    users(:mathew).logs.create!(workout: workout, score_type: :time, score_value: 400)
    fast = users(:mathew).logs.create!(workout: workout, score_type: :time, score_value: 330)

    records = users(:mathew).workout_records.select { |log| log.workout == workout }

    assert_equal [fast], records
  end

  test 'workout_records keeps the highest score for a rep-scored workout' do
    workout = workouts(:segmented_total_reps)
    users(:mathew).logs.create!(workout: workout, score_type: :rep, score_value: 100)
    more = users(:mathew).logs.create!(workout: workout, score_type: :rep, score_value: 150)

    records = users(:mathew).workout_records.select { |log| log.workout == workout }

    assert_equal [more], records
  end

  test 'workout_records shows a workout logged only once' do
    records = users(:mathew).workout_records

    assert_includes records, logs(:matt_murph)
  end

  test 'requires sex on user profiles' do
    user = User.new(
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      first_name: 'Test',
      last_name: 'User',
      weight: 180
    )

    assert_not user.valid?
    assert_includes user.errors[:sex], "can't be blank"
  end
end
