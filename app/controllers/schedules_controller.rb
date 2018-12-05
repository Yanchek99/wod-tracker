class SchedulesController < ApplicationController
  # GET /schedules
  # GET /schedules.json
  def index
    @schedules = Current.user.schedules
    return if @schedules.empty?

    @dates = @schedules.posted_dates.page(params[:page]).per(1)
    @date = @dates.first.posted_at.to_date
    @schedules = @schedules.where(posted_at: @date.beginning_of_day...@date.end_of_day)
  end
end
