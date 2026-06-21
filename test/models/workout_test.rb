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

  test 'assigns a content key from the workout structure on save' do
    workout = build_fran('Fran A')
    workout.save!

    assert workout.content_key.present?
    assert_equal workout.content_fingerprint, workout.content_key
  end

  test 'identical prescribed content fingerprints the same regardless of name' do
    assert_equal build_fran('One').content_fingerprint, build_fran('Two').content_fingerprint
  end

  test 'different prescribed content fingerprints differently' do
    heavier = build_fran('Heavier')
    heavier.exercises.first.load = 135

    assert_not_equal build_fran('Base').content_fingerprint, heavier.content_fingerprint
  end

  test 'the unique content key index rejects a duplicate workout' do
    build_fran('Original').save!

    assert_raises(ActiveRecord::RecordNotUnique) { build_fran('Duplicate').save! }
  end

  test 'a workout without parts has no content key' do
    workout = Workout.create!(name: 'Empty', score_type: :time)

    assert_nil workout.content_key
  end

  test 'prescription notes change the fingerprint' do
    noted = build_fran('Noted')
    noted.exercises.first.notes = '1 1/2 body weight'

    assert_not_equal build_fran('Plain').content_fingerprint, noted.content_fingerprint
  end

  test 'refreshes the content key when an exercise changes directly' do
    workout = build_fran('Direct')
    workout.save!
    original = workout.content_key

    workout.exercises.first.update!(notes: 'body weight')

    assert_not_equal original, workout.reload.content_key
  end

  test 'refreshes the content key when a part is added to an empty workout' do
    workout = Workout.create!(name: 'Grows', score_type: :time)
    assert_nil workout.content_key

    workout.exercises.create!(movement: movements(:pullup), position: 1, reps: 21)

    assert workout.reload.content_key.present?
  end

  test 'refreshes the content key when an exercise is destroyed directly' do
    workout = build_fran('Shrinks')
    workout.save!
    original = workout.content_key

    workout.exercises.find { |exercise| exercise.movement == movements(:pullup) }.destroy!

    assert_not_equal original, workout.reload.content_key
  end

  test 'excludes exercises marked for destruction from the fingerprint' do
    workout = build_fran('Trimmed')
    workout.save!

    remaining = Workout.new(name: 'Remaining', score_type: :time, interval: '21-15-9')
    remaining.exercises.build(movement: movements(:thruster), position: 1, reps: 1, load: 95, load_unit: :lb)

    workout.exercises.find { |exercise| exercise.movement == movements(:pullup) }.mark_for_destruction

    assert_equal remaining.content_fingerprint, workout.content_fingerprint
  end

  private

  def build_fran(name)
    Workout.new(name:, score_type: :time, interval: '21-15-9').tap do |workout|
      workout.exercises.build(movement: movements(:thruster), position: 1, reps: 1, load: 95, load_unit: :lb)
      workout.exercises.build(movement: movements(:pullup), position: 2, reps: 1)
    end
  end
end
