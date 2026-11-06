module ApplicationHelper
  def flash_bootstrap_class_for(flash_type)
    bootstrap_types = { success: 'alert-success', error: 'alert-danger', alert: 'alert-warning', notice: 'alert-info' }
    bootstrap_types[flash_type.to_sym] || flash_type.to_s
  end

  # Title for the phone top bar: a page's own content_for(:title), else its nav label, else the controller name.
  def page_title
    content_for(:title).presence || nav_items.find { |item| nav_active?(item) }&.label || controller_name.titleize
  end

  def user_initials(user)
    [user.first_name, user.last_name].compact_blank.pluck(0).join.upcase
  end

  # Ids of movements whose forms should show the implement-count field. Memoized per request so
  # the workout builder's many exercise rows share one query.
  def implement_count_movement_ids
    @implement_count_movement_ids ||= Movement.supporting_implement_count.ids
  end
end
