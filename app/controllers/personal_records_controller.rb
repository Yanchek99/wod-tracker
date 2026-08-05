class PersonalRecordsController < ApplicationController
  before_action :set_user

  def index
    redirect_to lifts_user_personal_records_path(@user)
  end

  def lifts
    @movement_logs = @user.personal_records.sort_by { |m| [m.movement.name, m.reps.to_i, m.distance.to_i, m.duration_seconds.to_i] }
  end

  def barbell
    @movement_rep_maxes = @user.personal_records
                               .select { |record| record.movement.family_weightlifting? }
                               .group_by(&:movement)
                               .sort_by { |movement, _records| movement.name }
                               .map { |movement, records| [movement, records.sort_by { |record| record.reps || Float::INFINITY }] }
  end

  def repeated_workouts
    @logs = @user.workout_records.sort_by { |log| log.workout.name }
  end

  private

  def set_user
    @user = User.find(params.expect(:user_id))
  end
end
