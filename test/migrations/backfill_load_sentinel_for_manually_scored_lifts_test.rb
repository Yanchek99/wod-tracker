require 'test_helper'
require Rails.root.join('db/migrate/20260721070000_backfill_load_sentinel_for_manually_scored_lifts').to_s

class BackfillLoadSentinelForManuallyScoredLiftsTest < ActiveSupport::TestCase
  M = BackfillLoadSentinelForManuallyScoredLifts

  test 'backfills affected exercises without changing unrelated loads' do
    exercises = M::AFFECTED_PAIRS.to_h do |workout_name, movement_name|
      [ [ workout_name, movement_name ], create_exercise(workout_name:, movement_name:) ]
    end
    unrelated = create_exercise(workout_name: 'Unrelated workout', movement_name: 'Unrelated movement', load: 135)

    M.new.up

    exercises.each_value { |exercise| assert_equal 0, exercise.reload.load }
    assert_equal 135, unrelated.reload.load
  end

  test 'raises when affected workouts are absent' do
    error = assert_raises(RuntimeError) { M.new.up }

    assert_match 'Open 15.1a', error.message
  end

  private

  def create_exercise(workout_name:, movement_name:, load: nil)
    workout = M::MigrationWorkout.find_or_create_by!(name: workout_name) { |record| record.score_type = 0 }
    movement = M::MigrationMovement.find_or_create_by!(name: movement_name)
    segment = M::MigrationSegment.find_or_create_by!(workout_id: workout.id, position: 1)
    M::MigrationExercise.create!(
      segment_id: segment.id,
      movement_id: movement.id,
      position: M::MigrationExercise.where(segment_id: segment.id).count + 1,
      load:
    )
  end
end
