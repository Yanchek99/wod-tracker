class MovementLogsController < ApplicationController
  before_action :set_user, only: [:personal_records]

  def personal_records
    @movement_logs = @user.personal_records.sort_by { |m| [m.movement.name, m.reps.to_i, m.distance.to_i, m.duration_seconds.to_i] }
  end

  private

  def set_user
    @user = User.find(params.expect(:user_id))
  end
end
