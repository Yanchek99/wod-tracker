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
