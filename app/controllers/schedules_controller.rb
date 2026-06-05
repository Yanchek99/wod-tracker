class SchedulesController < ApplicationController
  # GET /schedules
  # GET /schedules.json
  def index
    @schedules = Current.user.schedules
    return if @schedules.empty?

    @dates = @schedules.posted_dates.page(params[:page]).per(1)
    @date = @dates.first.posted_at
    @schedules = schedules_for_date
    @logged_workout_ids = logged_workout_ids_for(@schedules)
  end

  # POST /schedules
  # POST /schedules.json
  def create
    @schedule = Schedule.new(schedule_params)
    respond_to do |format|
      if @schedule.save
        format.html { redirect_to @schedule.workout, notice: t('.notice') }
        format.json { render :show, status: :created, location: @schedule.workout }
      else
        format.html { render :new }
        format.json { render json: @schedule.errors, status: :unprocessable_content }
      end
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def schedule_params
    params.expect(schedule: [:workout_id, :program_id, :posted_at])
  end

  def schedules_for_date
    @schedules
      .where(posted_at: @date.beginning_of_day...@date.end_of_day)
      .includes(
        :program,
        workout: [
          :metric,
          :rich_text_notes,
          { exercises: [:movement, :metrics, { segment: [:metric, :exercises] }] }
        ]
      )
  end

  def logged_workout_ids_for(schedules)
    workout_ids = schedules.map(&:workout_id)
    Current.user.logs.where(workout_id: workout_ids).distinct.pluck(:workout_id)
  end
end
