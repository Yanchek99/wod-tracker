class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_current_user
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def set_current_user
    Current.user = current_user
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name weight])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name weight])
  end
end
