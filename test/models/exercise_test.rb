require 'test_helper'

class ExerciseTest < ActiveSupport::TestCase
  test 'allows positions to repeat across different segments in the same workout' do
    workout = workouts(:segmented)
    first_segment = workout.segments.create!(position: 4)
    second_segment = workout.segments.create!(position: 5)

    first_segment.exercises.create!(movement: movements(:pullup), position: 1)
    exercise = second_segment.exercises.build(movement: movements(:pushup), position: 1)

    assert exercise.valid?
  end

  test 'rejects duplicate positions within the same segment' do
    workout = workouts(:segmented)
    segment = workout.segments.create!(position: 4)

    segment.exercises.create!(movement: movements(:pullup), position: 1)
    exercise = segment.exercises.build(movement: movements(:pushup), position: 1)

    assert_not exercise.valid?
    assert_includes exercise.errors[:position], 'has already been taken'
  end

  test 'rejects duplicate positions within the same unsaved segment' do
    workout = Workout.new(name: 'Invalid Segmented Seed Workout', score_type: :time)
    segment = workout.segments.build(rounds: 10, position: 1)
    exercise = segment.exercises.build(movement: movements(:pullup), position: 1)

    segment.exercises.build(movement: movements(:pushup), position: 1)

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

  # --- direct-column prescriptions (the #1651 read path) ---

  test 'a load unit with no fixed value sets the find-a-max sentinel' do
    exercise = fran_segment.exercises.build(movement: movements(:pullup), position: 3, load_unit: :lb)
    exercise.valid?

    assert_equal 0, exercise.load
    assert_predicate exercise, :load_bearing?
  end

  test 'score_component reads the rep prescription from columns' do
    exercise = fran_segment.exercises.build(movement: movements(:pullup), position: 3, reps: 21)

    assert_equal 21, exercise.score_component[:score_reps]
  end

  test 'score_component reads the calorie prescription from columns' do
    exercise = fran_segment.exercises.build(movement: movements(:row), position: 3, reps: 1, calories: 20)

    assert_equal 'calorie', exercise.score_component[:measurement]
    assert_equal 20, exercise.score_component[:score_reps]
  end

  test 'treats the reps zero sentinel as max and not scorable' do
    exercise = fran_segment.exercises.build(movement: movements(:pullup), position: 3, reps: 0)

    assert_nil exercise.score_component
  end

  test 'rejects a unisex value combined with sex-specific values' do
    exercise = fran_segment.exercises.build(movement: movements(:pullup), position: 3,
                                            load: 50, female_load: 65, male_load: 95, load_unit: :lb)

    assert_not exercise.valid?
    assert_includes exercise.errors[:load], 'cannot be set with sex-specific values'
  end

  test 'requires both sex-specific values when only one is present' do
    exercise = fran_segment.exercises.build(movement: movements(:pullup), position: 3,
                                            female_load: 65, load_unit: :lb)

    assert_not exercise.valid?
    assert_includes exercise.errors[:base], 'load requires both female and male values'
  end

  test 'validates distance units per rep against the column distance' do
    exercise = fran_segment.exercises.build(movement: movements(:run), position: 3,
                                            reps: 1, distance: 400, distance_unit: :meter,
                                            distance_units_per_rep: 30)

    assert_not exercise.valid?
    assert_includes exercise.errors[:distance_units_per_rep], 'must divide the prescribed distance evenly'
  end

  private

  # An unsaved segment for exercising Exercise validations/prescriptions in isolation,
  # independent of Fran's own persisted segment-less fixture exercises.
  def fran_segment
    workouts(:fran).segments.build(position: 1)
  end
end
