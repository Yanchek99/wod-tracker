require 'test_helper'

class WorkoutTest < ActiveSupport::TestCase
  test 'orders top-level exercises and segments as workout parts' do
    parts = workouts(:segmented).ordered_parts

    assert_equal [exercises(:segmented_run), segments(:test), exercises(:segmented_second_run)], parts
  end

  test 'orders unsaved exercises without a position last among workout parts' do
    workout = workouts(:segmented)
    unpositioned = workout.exercises.build(movement: movements(:run), position: nil)

    parts = workout.ordered_parts

    assert_equal [exercises(:segmented_run), segments(:test), exercises(:segmented_second_run), unpositioned], parts
  end

  test 'computes reps per round from rep exercises' do
    assert_equal 25, workouts(:amrap_couplet).amrap_reps_per_round
  end

  test 'computes reps per round from explicit distance, reps, and calories' do
    assert_equal 60, workouts(:amrap_mixed).amrap_reps_per_round
  end

  test 'does not compute reps per round for unconfigured distance' do
    assert_nil workouts(:amrap_unknown_distance).amrap_reps_per_round
  end

  test 'identifies segmented total-rep clocks' do
    assert_predicate workouts(:segmented_total_reps), :segmented_total_reps?
  end

  test 'does not identify empty segmented clocks as total-rep clocks' do
    workout = Workout.new(name: 'Empty Segments', time: 20, score_type: :rep)
    workout.segments.build(time_seconds: 300, position: 1)

    assert_not_predicate workout, :segmented_total_reps?
  end

  test 'distance scoring takes precedence over legacy rep marker' do
    component = exercises(:amrap_mixed_row).score_component

    assert_equal 'meter', component[:measurement]
    assert_equal 30, component[:score_reps]
  end

  test 'identifies set-based lifting workouts' do
    assert workouts(:back_squat_5x5).set_based_lifting?
    assert_not workouts(:amrap_couplet).set_based_lifting?
  end

  test 'does not identify rep-scored rounds with load-bearing exercises as set-based lifting' do
    workout = workouts(:back_squat_5x5)
    workout.update!(score_type: :rep)

    assert_not workout.set_based_lifting?
  end

  test 'identifies weight-scored rounds as set-based lifting without a prescribed load' do
    workout = workouts(:back_squat_5x5)
    workout.exercises.each { |exercise| exercise.update!(load: nil, load_unit: nil, female_load: nil, male_load: nil) }

    assert workout.reload.set_based_lifting?
  end
end
