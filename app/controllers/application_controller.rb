class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_current_user

  private

  def set_current_user
    Current.user = current_user
  end
end
