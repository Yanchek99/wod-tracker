require 'test_helper'

# The Intended stimulus panel on the workout page: calculated values carry a tag (#1992).
class WorkoutStimulusPanelTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @workout = workouts(:fran)
    sign_in users(:mathew)
  end

  test 'the stimulus panel renders for a workout with only predictions, tagging them calculated' do
    @workout.stimulus_predictions.create!(source: :predicted, model_version: 'learned-v1',
                                          stimulus_goal: :for_time, stimulus_range_high: 300, current: true)

    get workout_path(@workout)

    assert_select '.workout-stimulus', text: /For time/
    assert_select '.workout-stimulus .stimulus-calculated', minimum: 2
  end

  test 'extracted stimulus values render untagged' do
    @workout.update!(stimulus_range_high: 300, stimulus_source: :extracted)

    get workout_path(@workout)

    assert_select '.workout-stimulus', text: /≤ 5:00/
    assert_select '.workout-stimulus .stimulus-calculated', count: 0
  end
end
