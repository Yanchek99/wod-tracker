class PersonalRecordsController < ApplicationController
  before_action :set_user

  def index
    redirect_to family_user_personal_records_path(@user, family: 'weightlifting')
  end

  def family
    @family = params.expect(:family)
    if @family == 'weightlifting'
      @movement_rep_maxes = weightlifting_rep_maxes
      render :weightlifting
    else
      @movement_logs = family_movement_logs
      render :family
    end
  end

  def repeated_workouts
    @logs = @user.workout_records.sort_by { |log| log.workout.name }
  end

  private

  def weightlifting_rep_maxes
    @user.personal_records
         .select { |record| weightlifting_rep_max?(record) }
         .group_by(&:movement)
         .sort_by { |movement, _records| movement.name }
         .map { |movement, records| [movement, records.sort_by { |record| record.reps || Float::INFINITY }] }
  end

  def weightlifting_rep_max?(record)
    record.movement.family_weightlifting? && record.load.present?
  end

  def family_movement_logs
    @user.personal_records
         .select { |record| record.movement.public_send("family_#{@family}?") }
         .sort_by { |m| [m.movement.name, m.reps.to_i, m.distance.to_i, m.duration_seconds.to_i] }
  end

  def set_user
    @user = User.find(params.expect(:user_id))
  end
end
