class MovementLogsController < ApplicationController
  before_action :set_user, only: [:personal_records]

  def personal_records
    @movement_logs = @user.personal_records
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
