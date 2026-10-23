# Schedules a workout onto one program: the "Schedule workout" panel on the program page.
class ProgramSchedulesController < ApplicationController
  before_action :set_program

  def new
    @schedule = @program.schedules.build
    authorize! :create, @schedule
  end

  def create
    @schedule = @program.schedules.build(workout_id: params.dig(:schedule, :workout_id), posted_at: posted_at)
    authorize! :create, @schedule
    if @schedule.save
      redirect_to @program, notice: t('.notice'), status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_program
    @program = Program.find(params.expect(:program_id))
  end

  # Like scraped workouts, a hand-scheduled one is anchored to 6pm Pacific on the chosen day.
  def posted_at
    date = Date.iso8601(params.dig(:schedule, :posted_on).to_s)
    SchedulesController::POSTED_AT_ZONE.local(date.year, date.month, date.day, 18)
  rescue Date::Error
    nil
  end
end
