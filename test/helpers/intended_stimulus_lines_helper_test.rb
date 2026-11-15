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
    assert_equal ['Expected 3:00–5:00', true], stimulus_headline(workout)
  end

  test 'the headline puts the goal and the expected result on one line' do
    workout = Workout.new(score_type: :round, stimulus_goal: :amrap, stimulus_range_low: 12,
                          stimulus_range_high: 15, stimulus_source: :extracted)

    assert_match(/\AAMRAP · 12–15/, stimulus_headline(workout).first)
  end

  test 'a for-time goal is left out, since the workout already says it' do
    workout = Workout.new(score_type: :time, stimulus_goal: :for_time, stimulus_range_low: 690,
                          stimulus_range_high: 1380, stimulus_source: :extracted)

    assert_equal ['Expected 11:30–23:00', false], stimulus_headline(workout)
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

  test 'interval workout lines, without round time' do
    workout = Workout.new(score_type: :time, stimulus_round_seconds_high: 60, stimulus_interval_work_seconds: 270,
                          stimulus_interval_rest_seconds_min: 90, stimulus_source: :extracted)

    assert_equal [['Work', '≤ 4:30 per interval', false],
                  ['Rest', '≥ 1:30 per interval', false]], stimulus_workout_lines(workout)
  end

  test 'a movement line joins sets, time limit and rest, without the loading or effort label' do
    exercise = exercises(:fran_thruster)
    exercise.update!(stimulus_loading: :moderate, stimulus_sets_max: 3, stimulus_duration_max: 120,
                     stimulus_rest_max_seconds: 30, stimulus_effort: :sprint, stimulus_source: :extracted)

    assert_includes stimulus_movement_lines(workouts(:fran)),
                    ['Thruster', [['1–3 sets', false], ['under 2:00 per set', false], ['rest under 0:30', false]]]
  end

  test 'an extracted value next to a predicted one tags only the predicted value' do
    exercise = exercises(:fran_thruster)
    exercise.update!(stimulus_loading: :light, stimulus_sets_max: 1, stimulus_source: :extracted)
    exercise.stimulus_predictions.create!(source: :predicted, model_version: 'learned-v1',
                                          stimulus_duration_max: 90, current: true)

    assert_includes stimulus_movement_lines(workouts(:fran)),
                    ['Thruster', [['unbroken', false], ['under 1:30 per set', true]]]
  end

  test 'an unweighted movement has no movement line' do
    exercises(:fran_pullup).stimulus_predictions.create!(source: :predicted, model_version: 'learned-v1',
                                                         stimulus_loading: :unloaded, stimulus_sets_max: 1,
                                                         current: true)

    assert_not_includes stimulus_movement_lines(workouts(:fran)).map(&:first), 'Pull Up'
  end

  test 'a run gets a time line, though it is unweighted' do
    workout = Workout.create!(name: 'Run Line', score_type: :time)
    run = workout.segments.create!(position: 1, rounds: 5)
                 .exercises.create!(position: 1, movement: movements(:run), distance: 400, distance_unit: :meter)
    run.stimulus_predictions.create!(source: :derived, model_version: 'calc-v1', stimulus_loading: :unloaded,
                                     stimulus_duration_max: 120, current: true)

    assert_equal [['Run', [['under 2:00 per round', true]]]], stimulus_movement_lines(workout.reload)
  end

  test 'all calculated only when every shown value is' do
    assert stimulus_all_calculated?(['Expected 5:00', true], [], [['Thruster', [['unbroken', true]]]])
    assert_not stimulus_all_calculated?(['Expected 5:00', true], [], [['Thruster', [['unbroken', false]]]])
    assert_not stimulus_all_calculated?(nil, [], [])
  end
end
