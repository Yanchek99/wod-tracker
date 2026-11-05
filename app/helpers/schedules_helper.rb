module SchedulesHelper
  # An unscored log has no result to show; log_score_msg would render it as "1 time". A time under an hour reads
  # 5:00, not 00:05:00.
  def logged_result_msg(log)
    return 'Logged' if log.score_value.nil?

    log_score_msg(log).sub(/\A00:0?/, '')
  end

  # Kaminari renders nothing past either end of the range; keep a disabled button so the date doesn't shift.
  def day_step_button(link, icon_name, label)
    link || content_tag(:span, icon(icon_name), class: 'btn btn-outline-secondary btn-icon disabled',
                                                'aria-disabled': 'true', 'aria-label': label)
  end
end
