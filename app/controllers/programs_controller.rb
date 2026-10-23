class ProgramsController < ApplicationController
  load_and_authorize_resource

  def index
    @rows = ProgramListing.for(Current.user)
  end

  WORKOUTS_PER_PAGE = 10

  def show
    subscription = @program.subscriptions.find_by(user_id: Current.user.id)
    @role = subscription && (subscription.role || 'athlete')
    @followers = @program.subscriptions.count
    @workouts = @program.schedules.count
    load_past_schedules
  end

  # GET /programs/new
  def new
    @program = Program.new
  end

  # POST /programs
  # POST /programs.json
  def create
    @program = Program.new(program_params)
    @program.subscriptions.build(user: Current.user, role: :owner)
    respond_to do |format|
      if @program.save
        format.html { redirect_to @program, notice: t('.notice') }
        format.json { render :show, status: :created, location: @program }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @program.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /programs/1
  # DELETE /programs/1.json
  def destroy
    @program.destroy
    respond_to do |format|
      format.html { redirect_to programs_url, notice: t('.notice') }
      format.json { head :no_content }
    end
  end

  def subscribe
    @program.subscriptions.create(user: current_user, role: :athlete).save
    redirect_back_or_to @program, status: :see_other
  end

  def unsubscribe
    @program.subscriptions.find_by(user: current_user).destroy
    redirect_back_or_to @program, status: :see_other
  end

  private

  def load_past_schedules
    @schedules = @program.schedules.posted_through_today.order(posted_at: :desc)
                         .includes(workout: [:rich_text_notes, { segments: { exercises: :movement } }])
                         .page(params[:page]).per(WORKOUTS_PER_PAGE)
    @schedule_days = @schedules.group_by { |schedule| schedule.posted_at.in_time_zone(SchedulesController::POSTED_AT_ZONE).to_date }
  end

  # Only allow a list of trusted parameters through.
  def program_params
    params.expect(program: [:name])
  end
end
