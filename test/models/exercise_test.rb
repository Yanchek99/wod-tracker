require 'test_helper'

class ExerciseTest < ActiveSupport::TestCase
  test 'allows positions to repeat across different segments in the same workout' do
    workout = workouts(:segmented)
    first_segment = workout.segments.create!(position: 4)
    second_segment = workout.segments.create!(position: 5)

    workout.exercises.create!(movement: movements(:pullup), segment: first_segment, position: 1)
    exercise = workout.exercises.build(movement: movements(:pushup), segment: second_segment, position: 1)

    assert exercise.valid?
  end

  test 'rejects duplicate positions within the same segment' do
    workout = workouts(:segmented)
    segment = workout.segments.create!(position: 4)

    workout.exercises.create!(movement: movements(:pullup), segment:, position: 1)
    exercise = workout.exercises.build(movement: movements(:pushup), segment:, position: 1)

    assert_not exercise.valid?
    assert_includes exercise.errors[:position], 'has already been taken'
  end

  test 'rejects duplicate positions among top-level exercises in the same workout' do
    exercise = workouts(:fran).exercises.build(movement: movements(:run), position: 1)

    assert_not exercise.valid?
    assert_includes exercise.errors[:position], 'has already been taken'
  end

  test 'allows segment child positions to overlap top-level positions before segment is saved' do
    workout = Workout.new(name: 'Segmented Seed Workout', rounds: 1, score_type: :time)
    segment = workout.segments.build(rounds: 10, position: 2)

    workout.exercises.build(movement: movements(:run), position: 1)
    workout.exercises.build(movement: movements(:pullup), segment:, position: 1)
    workout.exercises.build(movement: movements(:pushup), segment:, position: 2)
    workout.exercises.build(movement: movements(:run), position: 3)

    assert workout.valid?
  end

  test 'rejects duplicate positions within the same unsaved segment' do
    workout = Workout.new(name: 'Invalid Segmented Seed Workout', rounds: 1)
    segment = workout.segments.build(rounds: 10, position: 1)
    exercise = workout.exercises.build(movement: movements(:pullup), segment:, position: 1)

    workout.exercises.build(movement: movements(:pushup), segment:, position: 1)

    assert_not exercise.valid?
    assert_includes exercise.errors[:position], 'has already been taken'
  end

  test 'rejects duplicate positions among new exercises in a persisted segment' do
    workout = workouts(:segmented)
    workout.assign_attributes(
      segments_attributes: [{ id: segments(:test).id,
                              exercises_attributes: [{ movement_id: movements(:pullup).id, position: 3 },
                                                     { movement_id: movements(:pushup).id, position: 3 }] }]
    )

    assert_not workout.valid?
    exercise = workout.segments.detect { |segment| segment.id == segments(:test).id }.exercises.detect(&:new_record?)
    assert_includes exercise.errors[:position], 'has already been taken'
  end

  test 'requires distance units per rep to divide prescribed distance evenly' do
    exercise = exercises(:amrap_mixed_row)

    exercise.distance_units_per_rep = 40

    assert_not exercise.valid?
    assert_includes exercise.errors[:distance_units_per_rep], 'must divide the prescribed distance evenly'
  end

  test 'requires a distance metric when distance units per rep is configured' do
    exercise = exercises(:amrap_couplet_pullup)

    exercise.distance_units_per_rep = 10

    assert_not exercise.valid?
    assert_includes exercise.errors[:distance_units_per_rep], 'requires a distance metric'
  end
end
