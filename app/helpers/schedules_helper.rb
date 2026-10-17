module SchedulesHelper
  SCORE_CHIPS = {
    'time' => 'For time', 'round' => 'Scored in rounds', 'rep' => 'Scored in reps',
    'calorie' => 'Scored in calories', 'weight' => 'Scored by load', 'inch' => 'Scored by height'
  }.freeze

  # Short facts shown above a scheduled workout: how it is scored and its time cap when it has one.
  def workout_chips(workout)
    [SCORE_CHIPS[workout.score_type.to_s], ("Time cap #{workout.time_cap}" if workout.time_cap_seconds.present?)].compact
  end
end
