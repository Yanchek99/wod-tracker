class SchedulesController < ApplicationController
  # GET /schedule/1
  # GET /schedule/1.json
  def show
    schedules = Current.user.schedules
    @dates = schedules.posted_dates.page(params[:page]).per(1)
    @date = @dates.first.posted_at.to_date
    @schedules = schedules.where(posted_at: @date.beginning_of_day...@date.end_of_day)
  end
end
