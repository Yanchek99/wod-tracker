require 'test_helper'
require Rails.root.join('db/migrate/20260721070000_backfill_load_sentinel_for_manually_scored_lifts').to_s

class BackfillLoadSentinelForManuallyScoredLiftsTest < ActiveSupport::TestCase
  M = BackfillLoadSentinelForManuallyScoredLifts

  test 'sets load: 0 on every exercise in AFFECTED_PAIRS' do
    seed_affected_exercises

    M.new.up

    M::AFFECTED_PAIRS.each do |workout_name, movement_name|
      exercise = exercise_for(workout_name, movement_name)
      assert_equal 0, exercise.reload.load, "expected #{workout_name} / #{movement_name} to have load: 0"
    end
  end

  test 'does not touch an unrelated exercise that already has a load' do
    seed_affected_exercises
    original_load = exercises(:fran_thruster).load

    M.new.up

    assert_equal original_load, exercises(:fran_thruster).reload.load
  end

  test 'raises if an affected workout is missing' do
    # No setup -- none of AFFECTED_PAIRS' workouts exist in the fixture-only database.
    assert_raises(RuntimeError) { M.new.up }
  end

  private

  def seed_affected_exercises
    M::AFFECTED_PAIRS.each do |workout_name, movement_name|
      movement = Movement.find_or_create_by!(name: movement_name)
      workout = Workout.find_or_create_by!(name: workout_name) { |w| w.score_type = :weight }
      segment = workout.segments.first || workout.segments.create!(position: 1)
      next if segment.exercises.exists?(movement_id: movement.id)

      segment.exercises.create!(movement: movement, position: segment.exercises.count + 1, reps: 1)
    end
  end

  def exercise_for(workout_name, movement_name)
    Workout.find_by!(name: workout_name).exercises.joins(:movement)
           .find_by!(movements: { name: movement_name })
  end
end
