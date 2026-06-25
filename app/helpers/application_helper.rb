module ApplicationHelper
  def flash_bootstrap_class_for(flash_type)
    bootstrap_types = { success: 'alert-success', error: 'alert-danger', alert: 'alert-warning', notice: 'alert-info' }
    bootstrap_types[flash_type.to_sym] || flash_type.to_s
  end

  def nav_item_class(name)
    "nav-item nav-link #{'active' if controller_name.to_sym.eql? name}"
  end

  # Ids of movements whose forms should show the implement-count field. Memoized per request so
  # the workout builder's many exercise rows share one query.
  def implement_count_movement_ids
    @implement_count_movement_ids ||= Movement.supporting_implement_count.ids
  end
end
