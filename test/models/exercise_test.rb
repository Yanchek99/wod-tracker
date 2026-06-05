require 'test_helper'

class ExerciseTest < ActiveSupport::TestCase
  test 'allows positions to repeat across different segments in the same workout' do
    workout = workouts(:segmented)
    first_segment = workout.segments.create!
    second_segment = workout.segments.create!

    workout.exercises.create!(movement: movements(:pullup), segment: first_segment, position: 1)
    exercise = workout.exercises.build(movement: movements(:pushup), segment: second_segment, position: 1)

    assert exercise.valid?
  end

  test 'rejects duplicate positions within the same segment' do
    workout = workouts(:segmented)
    segment = workout.segments.create!

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
