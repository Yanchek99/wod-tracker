module ApplicationHelper
  def flash_bootstrap_class_for(flash_type)
    bootstrap_types = { success: 'alert-success', error: 'alert-danger', alert: 'alert-warning', notice: 'alert-info' }
    bootstrap_types[flash_type.to_sym] || flash_type.to_s
  end
end
