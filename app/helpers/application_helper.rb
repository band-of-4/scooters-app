module ApplicationHelper
  def bootstrap_alert_class(flash_type)
    case flash_type.to_sym
    when :success
      "success"
    when :error, :alert, :danger
      "danger"
    when :warning
      "warning"
    when :notice
      "info"
    else
      "info"
    end
  end
end