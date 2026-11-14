require 'test_helper'

# The goal, workout-level and per-movement stimulus lines the panel renders (#1992).
class IntendedStimulusLinesHelperTest < ActionView::TestCase
  tests IntendedStimulusLinesHelper
  include SegmentsHelper
  include IntendedStimulusHelper

  test 'a weight-scored range renders as a percent of 1RM' do
    workout = Workout.new(score_type: :weight, stimulus_range_low: 85, stimulus_range_high: 90)

    assert_equal '85–90%', intended_stimulus_range(workout)
  end

  test 'the range falls back to the current prediction' do
    workout = workouts(:fran)
    workout.stimulus_predictions.create!(source: :predicted, model_version: 'learned-v1',
                                         stimulus_range_low: 180, stimulus_range_high: 300, current: true)

    assert_equal '3:00–5:00', intended_stimulus_range(workout)
    assert_includes stimulus_workout_lines(workout), ['Expected', '3:00–5:00', true]
  end

  test 'calculated? is true for a prediction and false for an extracted value' do
    predicted = IntendedStimulus::StimulusValue.new(value: 1, source: 'predicted', confidence: 0.5)
    extracted = IntendedStimulus::StimulusValue.new(value: 1, source: 'extracted', confidence: nil)

    assert stimulus_calculated?(predicted)
    assert_not stimulus_calculated?(extracted)
  end

  test 'goal label for a hold-percent heavy day' do
    workout = Workout.new(score_type: :weight, stimulus_goal: :heavy_hold_percent)

    assert_equal 'Heavy day: hold a percentage', stimulus_goal_label(workout)
  end

  test 'heavy-day workout lines' do
    workout = Workout.new(score_type: :weight, stimulus_percent_1rm_low: 70, stimulus_percent_1rm_high: 80,
                          stimulus_working_sets_low: 6, stimulus_working_sets_high: 8,
                          stimulus_rest_seconds_low: 120, stimulus_rest_seconds_high: 180, stimulus_source: :extracted)

    assert_equal [['Load', '70–80% of 1RM', false], ['Working sets', '6–8', false],
                  ['Rest', '2:00–3:00 between sets', false]], stimulus_workout_lines(workout)
  end

  test 'interval and round-time workout lines' do
    workout = Workout.new(score_type: :time, stimulus_round_seconds_high: 60, stimulus_interval_work_seconds: 270,
                          stimulus_interval_rest_seconds_min: 90, stimulus_source: :extracted)

    assert_equal [['Per round', '≤ 1:00', false], ['Work', '≤ 4:30 per interval', false],
                  ['Rest', '≥ 1:30 per interval', false]], stimulus_workout_lines(workout)
  end

  test 'a movement line joins loading, sets, time limit, rest and effort' do
    exercise = exercises(:fran_thruster)
    exercise.update!(stimulus_loading: :moderate, stimulus_sets_max: 3, stimulus_duration_max: 120,
                     stimulus_rest_max_seconds: 30, stimulus_effort: :sprint, stimulus_source: :extracted)

    assert_includes stimulus_movement_lines(workouts(:fran)),
                    ['Thruster', [['Moderate', false], ['3 sets or fewer', false], ['≤ 2:00', false],
                                  ['rest ≤ 0:30', false], ['Sprint', false]]]
  end

  test 'an extracted value next to a predicted one tags only the predicted value' do
    exercise = exercises(:fran_thruster)
    exercise.update!(stimulus_loading: :light, stimulus_source: :extracted)
    exercise.stimulus_predictions.create!(source: :predicted, model_version: 'learned-v1', stimulus_effort: :hard,
                                          current: true)

    assert_includes stimulus_movement_lines(workouts(:fran)), ['Thruster', [['Light', false], ['Hard', true]]]
  end

  test 'a movement line from a prediction is calculated and unbroken reads as unbroken' do
    exercises(:fran_pullup).stimulus_predictions.create!(source: :predicted, model_version: 'learned-v1',
                                                         stimulus_loading: :unloaded, stimulus_sets_max: 1,
                                                         current: true)

    assert_includes stimulus_movement_lines(workouts(:fran)), ['Pull Up', [['Unloaded', true], ['unbroken', true]]]
  end
end
