module ApplicationHelper
  def flash_bootstrap_class_for(flash_type)
    bootstrap_types = { success: 'alert-success', error: 'alert-danger', alert: 'alert-warning', notice: 'alert-info' }
    bootstrap_types[flash_type.to_sym] || flash_type.to_s
  end

  def nav_item_class(name)
    "nav-item nav-link #{'active' if controller_name.to_sym.eql? name}"
  end
end
