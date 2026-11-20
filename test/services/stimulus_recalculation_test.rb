require 'test_helper'

class StimulusRecalculationTest < ActiveSupport::TestCase
  setup do
    @workout = Workout.create!(name: 'Recalc Grace', score_type: :time)
    segment = @workout.segments.create!(position: 1)
    @clean_and_jerk = segment.exercises.create!(movement: movements(:clean_and_jerk), position: 1, reps: 30,
                                                male_load: 135, female_load: 95, load_unit: :lb)
  end

  test 'writes calc-v1 derived rows' do
    StimulusRecalculation.call

    row = @clean_and_jerk.stimulus_predictions.current.sole
    assert_equal ['moderate', 'derived', 'calc-v1', nil], row.values_at(:stimulus_loading, :source, :model_version, :confidence)
    assert_equal 'for_time', @workout.stimulus_predictions.current.sole.stimulus_goal
  end

  test 'skips fields that have their own extracted values' do
    @clean_and_jerk.update!(stimulus_loading: :heavy, stimulus_source: :extracted)

    StimulusRecalculation.call

    assert_nil @clean_and_jerk.stimulus_predictions.current.first&.stimulus_loading
  end

  test 'a rerun writes nothing new' do
    StimulusRecalculation.call

    assert_no_difference('StimulusPrediction.count') { StimulusRecalculation.call }
  end

  test 'retires a stale learned row when the calculator has nothing for it' do
    stale = workouts(:fran).stimulus_predictions.create!(source: :predicted, model_version: 'learned-v1',
                                                         stimulus_effort: :sprint, current: true)
    exercise = Exercise.joins(:movement).find_by!(movements: { name: 'Pull Up' }, segment: workouts(:fran).segments)
    old = exercise.stimulus_predictions.create!(source: :predicted, model_version: 'learned-v1',
                                                stimulus_effort: :hard, current: true)

    StimulusRecalculation.call

    assert_not old.reload.current
    assert_not stale.reload.current
  end

  test 'a dry run writes nothing and reports counts' do
    result = nil
    assert_no_difference('StimulusPrediction.count') { result = StimulusRecalculation.call(dry_run: true) }

    assert_operator result.exercises_written, :>=, 1
    assert_operator result.workouts_written, :>=, 1
  end
end
