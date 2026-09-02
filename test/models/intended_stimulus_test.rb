require 'test_helper'

# Behaviour of the IntendedStimulus concern, shared by Workout and Exercise.
class IntendedStimulusTest < ActiveSupport::TestCase
  test 'a workout prefers an authored range over any prediction' do
    workout = workouts(:fran)
    workout.update!(stimulus_range_low: 120, stimulus_range_high: 300, stimulus_source: :authored)
    workout.stimulus_predictions.create!(
      source: :predicted, model_version: 'net-1', confidence: 0.9, stimulus_range_high: 999, current: true
    )

    resolved = workout.intended_stimulus_for(:stimulus_range_high)

    assert_equal 300, resolved.value
    assert_equal 'authored', resolved.source
    assert_nil resolved.confidence
  end

  test 'a workout falls back to the current prediction, not a stale one' do
    workout = workouts(:fran)
    workout.stimulus_predictions.create!(source: :derived, model_version: 'rule-v0', stimulus_range_high: 111)
    workout.stimulus_predictions.create!(
      source: :predicted, model_version: 'net-1', confidence: 0.8, stimulus_range_high: 320, current: true
    )

    resolved = workout.intended_stimulus_for(:stimulus_range_high)

    assert_equal 320, resolved.value
    assert_equal 'predicted', resolved.source
    assert_in_delta 0.8, resolved.confidence
  end

  test 'resolution is nil when neither an authored value nor a current prediction exists' do
    assert_nil workouts(:fran).intended_stimulus_for(:stimulus_range_low)
  end

  test 'resolving a column that is not a stimulus field raises' do
    assert_raises(ArgumentError) { workouts(:fran).intended_stimulus_for(:time_cap_seconds) }
  end

  test 'a workout stimulus range high may not fall below the low end' do
    workout = workouts(:fran)
    workout.assign_attributes(stimulus_range_low: 300, stimulus_range_high: 120)

    assert_not_predicate workout, :valid?
  end

  test 'an exercise prefers an extracted loading over any prediction' do
    exercise = exercises(:fran_thruster)
    exercise.update!(stimulus_loading: :heavy, stimulus_source: :extracted)
    exercise.stimulus_predictions.create!(
      source: :derived, model_version: 'rule-v1', stimulus_loading: :light, current: true
    )

    resolved = exercise.intended_stimulus_for(:stimulus_loading)

    assert_equal 'heavy', resolved.value
    assert_equal 'extracted', resolved.source
  end

  test 'an exercise falls back to the current prediction' do
    exercise = exercises(:fran_thruster)
    exercise.stimulus_predictions.create!(
      source: :derived, model_version: 'rule-v1', confidence: 0.5, stimulus_sets_max: 3, current: true
    )

    resolved = exercise.intended_stimulus_for(:stimulus_sets_max)

    assert_equal 3, resolved.value
    assert_equal 'derived', resolved.source
    assert_in_delta 0.5, resolved.confidence
  end

  test 'stimulus_loading exposes the loading buckets as predicates' do
    exercise = exercises(:fran_thruster)
    exercise.stimulus_loading = :moderate

    assert_predicate exercise, :stimulus_loading_moderate?
  end

  test 'stimulus_sets_max must be a positive integer' do
    exercise = exercises(:fran_thruster)
    exercise.stimulus_sets_max = 0

    assert_not_predicate exercise, :valid?
  end
end
