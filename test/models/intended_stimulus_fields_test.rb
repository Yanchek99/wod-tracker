require 'test_helper'

# The goal, heavy-day, interval, rest and effort stimulus fields added for #1992.
class IntendedStimulusFieldsTest < ActiveSupport::TestCase
  test 'workout accepts every new stimulus field' do
    workout = workouts(:fran)
    workout.assign_attributes(
      stimulus_goal: :heavy_hold_percent,
      stimulus_percent_1rm_low: 70, stimulus_percent_1rm_high: 80,
      stimulus_working_sets_low: 5, stimulus_working_sets_high: 5,
      stimulus_rest_seconds_low: 120, stimulus_rest_seconds_high: 180,
      stimulus_round_seconds_low: 60, stimulus_round_seconds_high: 90,
      stimulus_interval_work_seconds: 270, stimulus_interval_rest_seconds_min: 90
    )

    assert_predicate workout, :valid?
    assert_predicate workout, :stimulus_goal_heavy_hold_percent?
  end

  test 'rejects an inverted pair for each range pair' do
    IntendedStimulus::RANGE_PAIRS.each do |low, high|
      workout = workouts(:fran)
      workout.assign_attributes(low => 10, high => 5)

      assert_not_predicate workout, :valid?, "#{low}/#{high} inverted should be invalid"
      assert_includes workout.errors.attribute_names, high.to_sym
    end
  end

  test 'percent of 1RM must be within 1..100' do
    workout = workouts(:fran)

    [0, 101].each do |value|
      workout.assign_attributes(stimulus_percent_1rm_low: value, stimulus_percent_1rm_high: nil)

      assert_not_predicate workout, :valid?, "#{value}% should be invalid"
    end

    [1, 100].each do |value|
      workout.assign_attributes(stimulus_percent_1rm_low: value, stimulus_percent_1rm_high: nil)

      assert_predicate workout, :valid?, "#{value}% should be valid"
    end
  end

  test 'a weight-scored workout range is a percent of 1RM' do
    workout = workouts(:fran)
    workout.assign_attributes(score_type: :weight, stimulus_range_low: 85, stimulus_range_high: 101)

    assert_not_predicate workout, :valid?

    workout.stimulus_range_high = 90

    assert_predicate workout, :valid?
  end

  test 'an exercise exposes rest limit and effort' do
    exercise = exercises(:fran_thruster)
    exercise.assign_attributes(stimulus_rest_max_seconds: 10, stimulus_effort: :sprint)

    assert_predicate exercise, :valid?
    assert_predicate exercise, :stimulus_effort_sprint?

    exercise.stimulus_rest_max_seconds = 0

    assert_not_predicate exercise, :valid?
  end

  test 'intended_stimulus_for resolves new fields from the current prediction' do
    exercise = exercises(:fran_thruster)
    exercise.stimulus_predictions.create!(
      source: :derived, model_version: 'rules-v1', stimulus_effort: :sprint, current: true
    )

    resolved = exercise.intended_stimulus_for(:stimulus_effort)

    assert_equal 'sprint', resolved.value
    assert_equal 'derived', resolved.source
  end

  test 'a workout resolves its goal from the current prediction' do
    workout = workouts(:fran)
    workout.stimulus_predictions.create!(
      source: :predicted, model_version: 'learned-v1', stimulus_goal: :for_time, current: true
    )

    assert_equal 'for_time', workout.intended_stimulus_for(:stimulus_goal).value
  end
end
