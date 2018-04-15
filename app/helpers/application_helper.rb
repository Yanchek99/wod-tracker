module ApplicationHelper
  def flash_bootstrap_class_for flash_type
    bootstrap_types = { success: "alert-success", error: "alert-danger", alert: "alert-warning", notice: "alert-info" }
    bootstrap_types[flash_type] || flash_type.to_s
  end

  def flash_messages(opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(:p, message, class: "alert #{flash_bootstrap_class_for(msg_type)} fade in") do
              concat content_tag(:button, 'x', class: "close", data: { dismiss: 'alert' })
              concat message
            end)
    end
    nil
  end
end
