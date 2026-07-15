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

  test 'normalizes blank interval strings away from generated segments' do
    workout = Workout.create!(name: 'Blank Interval', score_type: :time, interval: '')
    workout.exercises.create!(movement: movements(:run), position: 1, reps: 1)

    BackfillSegmentsForTopLevelExercises.new.up

    segment = workout.reload.segments.sole
    assert_nil segment.interval_scheme
    assert_nil segment.rounds
    assert_nil segment.time_seconds
  end

  test 'ignores malformed top-level exercises without a workout id' do
    # Simulates legacy/bad data that cannot be built through the app model validations.
    # rubocop:disable Rails/SkipsModelValidations
    Exercise.insert!({
                       movement_id: movements(:run).id,
                       position: 1,
                       reps: 1,
                       created_at: Time.current,
                       updated_at: Time.current
                     })
    # rubocop:enable Rails/SkipsModelValidations

    assert_nothing_raised { BackfillSegmentsForTopLevelExercises.new.up }
  ensure
    Exercise.unscoped.where(workout_id: nil).delete_all
  end

  test 'converts workout time from minutes to segment seconds' do
    workout = Workout.create!(name: 'Time Domain', score_type: :time, time: 12)
    workout.exercises.create!(movement: movements(:run), position: 1, reps: 400)

    BackfillSegmentsForTopLevelExercises.new.up

    assert_equal 720, workout.reload.segments.sole.time_seconds
  end

  test 'absorbs a duplicate created by wrapping exercises into an equivalent segment' do
    canonical = Workout.create!(name: 'Segmented Fran', score_type: :time, interval: '21-15-9')
    segment = canonical.segments.create!(position: 1, interval_scheme: '21-15-9')
    segment.exercises.create!(movement: movements(:thruster), position: 1, reps: 1)
    segment.exercises.create!(movement: movements(:pull_up), position: 2, reps: 1)

    duplicate = Workout.create!(name: 'Flat Fran', score_type: :time, interval: '21-15-9')
    duplicate.exercises.create!(movement: movements(:thruster), position: 1, reps: 1)
    duplicate.exercises.create!(movement: movements(:pull_up), position: 2, reps: 1)

    assert_difference('Workout.count', -1) do
      BackfillSegmentsForTopLevelExercises.new.up
    end

    assert_not Workout.exists?(duplicate.id)
    assert_equal canonical.reload.content_fingerprint, canonical.content_key
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

  test 'wraps a plain unschemed workout as an implicit segment' do
    workout = Workout.create!(name: 'Plain Chipper', score_type: :time)
    workout.exercises.create!(movement: movements(:run), position: 1, reps: 400)
    workout.exercises.create!(movement: movements(:pull_up), position: 2, reps: 10)

    BackfillSegmentsForTopLevelExercises.new.up

    segment = workout.reload.segments.sole
    assert_predicate segment, :implicit_workout_part?
    assert_nil segment.rounds
    assert_nil segment.time_seconds
    assert_nil segment.interval_scheme
    assert_empty workout.exercises.where(segment_id: nil)
  end

  test 'raises for multiple exercise runs in a workout with a scheme' do
    workout = Workout.create!(name: 'Ambiguous', score_type: :time, rounds: 3)
    workout.exercises.create!(movement: movements(:run), position: 1, reps: 400)
    workout.segments.create!(name: 'Break', position: 2)
    workout.exercises.create!(movement: movements(:pull_up), position: 3, reps: 10)

    assert_raises(RuntimeError) { BackfillSegmentsForTopLevelExercises.new.up }
  end
end
