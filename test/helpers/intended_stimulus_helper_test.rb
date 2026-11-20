require 'test_helper'

class IntendedStimulusHelperTest < ActionView::TestCase
  include SegmentsHelper

  test 'formats a time-scored range as a clock range' do
    workout = Workout.new(score_type: :time, stimulus_range_low: 180, stimulus_range_high: 605)

    assert_equal '3:00–10:05', intended_stimulus_range(workout)
  end

  test 'a calculated time window reads in whole minutes, half minutes under 10:00' do
    nancy = Workout.create!(name: 'Nancy Window', score_type: :time)
    nancy.stimulus_predictions.create!(source: :derived, model_version: 'calc-v1', stimulus_range_low: 690,
                                       stimulus_range_high: 1104, current: true)
    fran = Workout.create!(name: 'Fran Window', score_type: :time)
    fran.stimulus_predictions.create!(source: :derived, model_version: 'calc-v1', stimulus_range_low: 230,
                                      stimulus_range_high: 368, current: true)

    assert_equal '11:00–18:00', intended_stimulus_range(nancy)
    assert_equal '3:30–6:00', intended_stimulus_range(fran)
  end

  test 'formats a rep-scored lone ceiling' do
    workout = Workout.new(score_type: :rep, stimulus_range_high: 250)

    assert_equal '≤ 250 reps', intended_stimulus_range(workout)
  end

  test 'collapses an equal low and high to one value' do
    workout = Workout.new(score_type: :round, stimulus_range_low: 12, stimulus_range_high: 12)

    assert_equal '12 rounds', intended_stimulus_range(workout)
  end

  test 'is nil without a range' do
    assert_nil intended_stimulus_range(Workout.new(score_type: :time))
  end
end
