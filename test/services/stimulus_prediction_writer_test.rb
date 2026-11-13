require 'test_helper'

class StimulusPredictionWriterTest < ActiveSupport::TestCase
  setup do
    @exercise = exercises(:fran_thruster)
  end

  test 'creates exactly one current row' do
    assert_equal :created, write(stimulus_loading: 'light', stimulus_sets_max: 1)

    rows = @exercise.stimulus_predictions
    assert_equal 1, rows.current.count
    assert_equal %w[light predicted learned-v1], rows.current.first.values_at(:stimulus_loading, :source, :model_version)
  end

  test 'identical rerun returns :unchanged and adds no row' do
    write(stimulus_loading: 'light')

    assert_no_difference('StimulusPrediction.count') do
      assert_equal :unchanged, write(stimulus_loading: 'light')
    end
  end

  test 'a changed value flips the previous current to false and adds one row' do
    write(stimulus_loading: 'light')

    assert_difference('StimulusPrediction.count', 1) { write(stimulus_loading: 'moderate') }
    assert_equal ['moderate'], @exercise.stimulus_predictions.current.pluck(:stimulus_loading)
    assert_equal 2, @exercise.stimulus_predictions.count
  end

  test 'a new model_version with the same values adds a row' do
    write(stimulus_loading: 'light')

    assert_difference('StimulusPrediction.count', 1) { write({ stimulus_loading: 'light' }, model_version: 'learned-v2') }
    assert_equal 1, @exercise.stimulus_predictions.current.count
  end

  test 'empty values writes nothing' do
    assert_no_difference('StimulusPrediction.count') { assert_equal :skipped, write({}) }
  end

  test 'never writes to the target own stimulus columns' do
    write(stimulus_loading: 'heavy', stimulus_effort: 'sprint')

    assert_nil @exercise.reload.stimulus_loading
    assert_nil @exercise.stimulus_effort
  end

  test 'writes a workout-level row' do
    workout = workouts(:fran)

    StimulusPredictionWriter.write(workout, StimulusPredictionWriter::Row.new(values: { stimulus_goal: 'for_time', stimulus_range_high: 300 },
                                                                              source: :predicted, model_version: 'learned-v1',
                                                                              confidence: 0.4))

    assert_equal ['for_time', 300], workout.stimulus_predictions.current.first.values_at(:stimulus_goal, :stimulus_range_high)
  end

  private

  def write(values = nil, model_version: 'learned-v1', **fields)
    row = StimulusPredictionWriter::Row.new(values: values || fields, source: :predicted, model_version:, confidence: 0.5)
    StimulusPredictionWriter.write(@exercise, row)
  end
end
