require 'test_helper'
require Rails.root.join('db/migrate/20260713120000_backfill_segments_for_top_level_exercises').to_s

class BackfillSegmentsForTopLevelExercisesTest < ActiveSupport::TestCase
  test 'wraps a flat interval workout in one segment' do
    workout = Workout.create!(name: 'Fran', score_type: :time, interval: '21-15-9')
    workout.exercises.create!(movement: movements(:thruster), position: 1, reps: 1)
    workout.exercises.create!(movement: movements(:pull_up), position: 2, reps: 1)
    stale_content_key = workout.reload.content_key

    BackfillSegmentsForTopLevelExercises.new.up

    assert_equal 1, workout.segments.count
    segment = workout.reload.segments.first
    assert_equal '21-15-9', segment.interval_scheme
    assert_nil segment.rounds
    assert_equal [1, 2], segment.exercises.order(:position).pluck(:position)
    assert_empty workout.exercises.where(segment_id: nil)
    assert_not_equal stale_content_key, workout.reload.content_key
    assert_equal workout.content_fingerprint, workout.content_key
  end

  test 'converts workout time from minutes to segment seconds' do
    workout = Workout.create!(name: 'Time Domain', score_type: :time, time: 12)
    workout.exercises.create!(movement: movements(:run), position: 1, reps: 400)

    BackfillSegmentsForTopLevelExercises.new.up

    assert_equal 720, workout.reload.segments.sole.time_seconds
  end

  test 'preserves existing segments when wrapping a leading rounds run' do
    workout = Workout.create!(name: 'Brenton', score_type: :time, rounds: 5)
    workout.exercises.create!(movement: movements(:run), position: 1, reps: 400)
    existing_segment = workout.segments.create!(name: 'Carry', position: 2)

    BackfillSegmentsForTopLevelExercises.new.up

    assert_equal 2, workout.segments.count
    new_segment = workout.segments.find_by!(position: 1)
    assert_equal 5, new_segment.rounds
    assert_equal 1, new_segment.position
    assert_equal 'Carry', existing_segment.reload.name
    assert_equal 2, existing_segment.position
  end

  test 'wraps a middle run without a scheme' do
    workout = Workout.create!(name: 'Alec', score_type: :time, rounds: 1)
    workout.segments.create!(name: 'First', position: 1)
    workout.exercises.create!(movement: movements(:run), position: 2, reps: 400)
    workout.segments.create!(name: 'Last', position: 5)

    BackfillSegmentsForTopLevelExercises.new.up

    assert_equal 3, workout.segments.count
    middle_segment = workout.segments.find_by!(position: 2)
    assert_nil middle_segment.rounds
    assert_nil middle_segment.time_seconds
    assert_equal [movements(:run)], middle_segment.exercises.map(&:movement)
  end

  test 'raises for multiple exercise runs in a workout with a scheme' do
    workout = Workout.create!(name: 'Ambiguous', score_type: :time, rounds: 3)
    workout.exercises.create!(movement: movements(:run), position: 1, reps: 400)
    workout.segments.create!(name: 'Break', position: 2)
    workout.exercises.create!(movement: movements(:pull_up), position: 3, reps: 10)

    assert_raises(RuntimeError) { BackfillSegmentsForTopLevelExercises.new.up }
  end
end
