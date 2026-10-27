module SchedulesHelper
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
