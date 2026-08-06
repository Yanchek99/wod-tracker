require 'test_helper'

class MovementRecordSetTest < ActiveSupport::TestCase
  test 'groups load-bearing logs by rep count and keeps the heaviest load per rep count' do
    five_rep_heavy = MovementLog.new(movement_id: 1, load: 275, reps: 5)
    five_rep_light = MovementLog.new(movement_id: 1, load: 225, reps: 5)
    fifty_two_rep = MovementLog.new(movement_id: 1, load: 185, reps: 52)

    records = MovementRecordSet.new([five_rep_heavy, five_rep_light, fifty_two_rep]).records

    assert_includes records, five_rep_heavy
    assert_includes records, fifty_two_rep
    assert_not_includes records, five_rep_light
    assert_equal 2, records.size
  end

  test 'does not let an earlier-logged low load beat a later-logged high load in the same rep-count group' do
    logged_first_and_lighter = MovementLog.new(movement_id: 8, load: 225, reps: 5)
    logged_second_and_heavier = MovementLog.new(movement_id: 8, load: 275, reps: 5)

    records = MovementRecordSet.new([logged_first_and_lighter, logged_second_and_heavier]).records

    assert_equal [logged_second_and_heavier], records
  end

  test 'ranks distance-plus-duration logs by the fastest time within the same distance' do
    slow500 = MovementLog.new(movement_id: 2, distance: 500, duration_seconds: 120)
    fast500 = MovementLog.new(movement_id: 2, distance: 500, duration_seconds: 105)
    a2000 = MovementLog.new(movement_id: 2, distance: 2000, duration_seconds: 450)

    records = MovementRecordSet.new([slow500, fast500, a2000]).records

    assert_includes records, fast500
    assert_includes records, a2000
    assert_not_includes records, slow500
    assert_equal 2, records.size
  end

  test 'skips a bare distance with no load or duration' do
    distance_only = MovementLog.new(movement_id: 3, distance: 5000)

    assert_empty MovementRecordSet.new([distance_only]).records
  end

  test 'ranks duration-plus-reps logs by the most reps within the same duration' do
    fewer_reps = MovementLog.new(movement_id: 4, duration_seconds: 60, reps: 40)
    more_reps = MovementLog.new(movement_id: 4, duration_seconds: 60, reps: 55)

    records = MovementRecordSet.new([fewer_reps, more_reps]).records

    assert_equal [more_reps], records
  end

  test 'ranks duration-plus-calories logs by the most calories within the same duration' do
    fewer_calories = MovementLog.new(movement_id: 5, duration_seconds: 240, calories: 60)
    more_calories = MovementLog.new(movement_id: 5, duration_seconds: 240, calories: 75)

    records = MovementRecordSet.new([fewer_calories, more_calories]).records

    assert_equal [more_calories], records
  end

  test 'keeps the highest calories-only log as a single record' do
    fewer = MovementLog.new(movement_id: 6, calories: 20)
    more = MovementLog.new(movement_id: 6, calories: 30)

    records = MovementRecordSet.new([fewer, more]).records

    assert_equal [more], records
  end

  test 'keeps the highest reps-only log as a single record' do
    fewer = MovementLog.new(movement_id: 7, reps: 10)
    more = MovementLog.new(movement_id: 7, reps: 15)

    records = MovementRecordSet.new([fewer, more]).records

    assert_equal [more], records
  end

  test 'keeps records from different movements independent' do
    deadlift = MovementLog.new(movement_id: 9, load: 315, reps: 1)
    back_squat = MovementLog.new(movement_id: 10, load: 405, reps: 1)

    records = MovementRecordSet.new([deadlift, back_squat]).records

    assert_includes records, deadlift
    assert_includes records, back_squat
    assert_equal 2, records.size
  end

  test 'ranks a fixed load/reps/distance test by the fastest time' do
    slow = MovementLog.new(movement_id: 11, load: 45, reps: 1000, distance: 20, duration_seconds: 4183)
    faster = MovementLog.new(movement_id: 11, load: 45, reps: 1000, distance: 20, duration_seconds: 4057)
    fastest = MovementLog.new(movement_id: 11, load: 45, reps: 1000, distance: 20, duration_seconds: 3752)

    records = MovementRecordSet.new([slow, faster, fastest]).records

    assert_equal [fastest], records
  end

  test 'still ranks a find-a-max-with-time-cap test by load when no distance is recorded' do
    light = MovementLog.new(movement_id: 12, load: 225, reps: 4, duration_seconds: 240)
    heavy = MovementLog.new(movement_id: 12, load: 245, reps: 4, duration_seconds: 240)

    records = MovementRecordSet.new([light, heavy]).records

    assert_equal [heavy], records
  end
end
