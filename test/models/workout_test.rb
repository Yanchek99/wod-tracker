require 'test_helper'

class WorkoutTest < ActiveSupport::TestCase
  test 'orders top-level exercises and segments as workout parts' do
    parts = workouts(:segmented).ordered_parts

    assert_equal [exercises(:segmented_run), segments(:test), exercises(:segmented_second_run)], parts
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
    workout.metric.update!(measurement: :rep)

    assert_not workout.set_based_lifting?
  end
end
