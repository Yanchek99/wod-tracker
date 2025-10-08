class SchedulesController < ApplicationController
  # GET /schedules
  # GET /schedules.json
  def index
    @schedules = Current.user.schedules
    return if @schedules.empty?

    @dates = @schedules.posted_dates.page(params[:page]).per(1)
    @date = @dates.first.posted_at
    @schedules = @schedules.where(posted_at: @date.beginning_of_day...@date.end_of_day)
  end

  # POST /schedules
  # POST /schedules.json
  def create
    @schedule = Schedule.new(schedule_params)
    respond_to do |format|
      if @schedule.save
        format.html { redirect_to @schedule.workout, notice: t('.create.notice') }
        format.json { render :show, status: :created, location: @schedule.workout }
      else
        format.html { render :new }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def schedule_params
    params.expect(schedule: [:workout_id, :program_id, :posted_at])
  end
end
