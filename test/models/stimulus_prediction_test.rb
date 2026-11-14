require 'test_helper'

class StimulusPredictionTest < ActiveSupport::TestCase
  test 'valid with exactly one target' do
    prediction = StimulusPrediction.new(workout: workouts(:fran), source: :derived, model_version: 'rule-v1')

    assert_predicate prediction, :valid?
  end

  test 'invalid with neither a workout nor an exercise' do
    prediction = StimulusPrediction.new(source: :derived, model_version: 'rule-v1')

    assert_not_predicate prediction, :valid?
  end

  test 'invalid with both a workout and an exercise' do
    prediction = StimulusPrediction.new(
      workout: workouts(:fran), exercise: exercises(:fran_thruster), source: :derived, model_version: 'rule-v1'
    )

    assert_not_predicate prediction, :valid?
  end

  test 'requires a model version' do
    prediction = StimulusPrediction.new(workout: workouts(:fran), source: :predicted)

    assert_not_predicate prediction, :valid?
  end

  test 'confidence must be within 0..1' do
    prediction = StimulusPrediction.new(
      workout: workouts(:fran), source: :predicted, model_version: 'net-1', confidence: 1.5
    )

    assert_not_predicate prediction, :valid?
  end

  test 'carries every new stimulus field' do
    prediction = StimulusPrediction.new(
      workout: workouts(:fran), source: :predicted, model_version: 'learned-v1',
      stimulus_goal: :heavy_find_max, stimulus_percent_1rm_low: 80, stimulus_percent_1rm_high: 90,
      stimulus_working_sets_low: 6, stimulus_working_sets_high: 8,
      stimulus_rest_seconds_low: 120, stimulus_rest_seconds_high: 180,
      stimulus_round_seconds_low: 60, stimulus_round_seconds_high: 90,
      stimulus_interval_work_seconds: 270, stimulus_interval_rest_seconds_min: 90
    )

    assert_predicate prediction, :valid?
    assert_predicate prediction, :stimulus_goal_heavy_find_max?
  end

  test 'an exercise prediction carries rest limit and effort' do
    prediction = StimulusPrediction.new(
      exercise: exercises(:fran_thruster), source: :derived, model_version: 'rules-v1',
      stimulus_rest_max_seconds: 30, stimulus_effort: :threshold
    )

    assert_predicate prediction, :valid?
  end

  test 'rejects an inverted range pair and an out-of-range percent' do
    inverted = StimulusPrediction.new(workout: workouts(:fran), source: :predicted, model_version: 'learned-v1',
                                      stimulus_working_sets_low: 8, stimulus_working_sets_high: 6)
    over = StimulusPrediction.new(workout: workouts(:fran), source: :predicted, model_version: 'learned-v1',
                                  stimulus_percent_1rm_high: 120)

    assert_not_predicate inverted, :valid?
    assert_not_predicate over, :valid?
  end

  test 'current scope returns only current rows' do
    live = StimulusPrediction.create!(
      workout: workouts(:fran), source: :derived, model_version: 'rule-v1', current: true
    )
    StimulusPrediction.create!(workout: workouts(:fran), source: :derived, model_version: 'rule-v0')

    assert_equal [live], StimulusPrediction.current.to_a
  end

  test 'the database rejects a row targeting both a workout and an exercise' do
    prediction = StimulusPrediction.new(
      workout: workouts(:fran), exercise: exercises(:fran_thruster), source: :derived, model_version: 'rule-v1'
    )

    assert_raises(ActiveRecord::StatementInvalid) { prediction.save!(validate: false) }
  end

  test 'destroying a workout destroys its predictions' do
    workout = build_fran
    workout.save!
    workout.stimulus_predictions.create!(source: :derived, model_version: 'rule-v1', current: true)

    assert_difference 'StimulusPrediction.count', -1 do
      workout.destroy!
    end
  end

  private

  def build_fran(name = 'Fran For Predictions')
    Workout.new(name:, score_type: :time).tap do |workout|
      segment = workout.segments.build(interval_scheme: '21-15-9', position: 1)
      segment.exercises.build(movement: movements(:thruster), position: 1, reps: 1, load: 95)
      segment.exercises.build(movement: movements(:pullup), position: 2, reps: 1)
    end
  end
end
