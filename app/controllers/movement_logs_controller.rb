class MovementLogsController < ApplicationController
  before_action :set_user, only: [:personal_records]

  def personal_records
    @movement_logs = @user.personal_records.sort_by { |m| m.movement.name }
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
