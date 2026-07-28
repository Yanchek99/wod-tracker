class WorkoutRecordsController < ApplicationController
  before_action :set_user

  def index
    @logs = @user.workout_records.sort_by { |log| log.workout.name }
  end

  private

  def set_user
    @user = User.find(params.expect(:user_id))
  end
end
