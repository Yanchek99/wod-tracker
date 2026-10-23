module SchedulesHelper
  SCORE_CHIPS = {
    'time' => 'For time', 'round' => 'Scored in rounds', 'rep' => 'Scored in reps',
    'calorie' => 'Scored in calories', 'weight' => 'Scored by load', 'inch' => 'Scored by height'
  }.freeze

  # Short facts shown above a scheduled workout: how it is scored and its time cap when it has one.
  def workout_chips(workout)
    [SCORE_CHIPS[workout.score_type.to_s], ("Time cap #{workout.time_cap}" if workout.time_cap_seconds.present?)].compact
  end

  # An unscored log has no result to show; log_score_msg would render it as "1 time".
  def logged_result_msg(log)
    log.score_value.nil? ? 'Logged' : log_score_msg(log)
  end

  # Kaminari renders nothing past either end of the range; keep a disabled button so the date doesn't shift.
  def day_step_button(link, icon_name, label)
    link || content_tag(:span, icon(icon_name), class: 'btn btn-outline-secondary btn-icon disabled',
                                                'aria-disabled': 'true', 'aria-label': label)
  end
end
