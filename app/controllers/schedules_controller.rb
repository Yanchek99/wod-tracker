class SchedulesController < ApplicationController
  # ScrapeCfWodJob anchors posted_at to 6pm America/Los_Angeles (see its posted_at_for), which
  # falls after UTC midnight -- the app's own Time.zone -- for most of the day. Deriving a
  # schedule's calendar date in that default zone (a bare `.to_date`) shows every CF.com workout
  # one day later than the day it was actually posted for; this must use the same zone it was
  # anchored in instead.
  POSTED_AT_ZONE = ActiveSupport::TimeZone['America/Los_Angeles'].freeze

  # GET /schedules
  # GET /schedules.json
  def index
    @schedules = Current.user.schedules
    return if @schedules.empty?

    @dates = @schedules.posted_dates.page(target_page).per(1)
    @date = @dates.first.posted_at
    @calendar_date = calendar_date_for(@date)
    @scheduled_dates = @schedules.posted_dates.pluck(:posted_at).map { |posted_at| calendar_date_for(posted_at) }
    @schedules = schedules_for_date
    load_histories_and_week
    @today = @calendar_date == POSTED_AT_ZONE.today
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

  # Maps a picked `date` param onto the Kaminari page of distinct posted
  # dates (ordered desc) that it falls on, snapping to the nearest earlier
  # scheduled date and clamping to the available range.
  def target_page
    return params[:page] if params[:date].blank?

    target_date = Date.parse(params[:date])
    total = @schedules.posted_dates.count
    page = @schedules.posted_dates.where(posted_at: end_of_calendar_day(target_date)...).count + 1
    page.clamp(1, total)
  rescue ArgumentError, TypeError
    params[:page]
  end

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
          :rich_text_notes,
          { segments: { exercises: :movement } }
        ]
      )
  end

  def load_histories_and_week
    week_workout_ids = week_workout_ids_for(@calendar_date)
    @workout_histories = workout_histories_for(@schedules, week_workout_ids)
    @week = ScheduleWeek.new(workout_ids: week_workout_ids, histories: @workout_histories, period: week_period(@calendar_date))
  end

  # One logs query serves the day's workouts and the rest of the week's: whether each was logged, the last
  # result and the best.
  def workout_histories_for(schedules, week_workout_ids)
    workouts = schedules.index_by(&:workout_id).transform_values(&:workout)
    logs = Current.user.logs.where(workout_id: workouts.keys | week_workout_ids).includes(:workout).to_a
    # Reuse the schedules' already-loaded workouts so scoring a log doesn't reload their segments and exercises.
    logs.each { |log| log.association(:workout).target = workouts[log.workout_id] if workouts.key?(log.workout_id) }
    WorkoutHistory.for(logs)
  end

  def week_workout_ids_for(calendar_date)
    Current.user.schedules.where(posted_at: week_period(calendar_date)).distinct.pluck(:workout_id)
  end

  # Monday through Sunday around the shown calendar day, in the zone schedules are anchored to.
  def week_period(calendar_date)
    calendar_date.beginning_of_week.in_time_zone(POSTED_AT_ZONE)...(calendar_date.end_of_week + 1).in_time_zone(POSTED_AT_ZONE)
  end

  def calendar_date_for(instant)
    instant.in_time_zone(POSTED_AT_ZONE).to_date
  end

  def end_of_calendar_day(date)
    POSTED_AT_ZONE.local(date.year, date.month, date.day, 23, 59, 59)
  end
end
