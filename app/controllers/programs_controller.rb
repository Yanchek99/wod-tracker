class ProgramsController < ApplicationController
  load_and_authorize_resource

  def index
    @programs = Program.all.order(:name)
  end

  def show; end

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
        format.html { redirect_to @program, notice: t('.create.notice') }
        format.json { render :show, status: :created, location: @program }
      else
        format.html { render :new }
        format.json { render json: @program.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /programs/1
  # DELETE /programs/1.json
  def destroy
    @program.destroy
    respond_to do |format|
      format.html { redirect_to programs_url, notice: t('.destroy.notice') }
      format.json { head :no_content }
    end
  end

  def subscribe
    @program.subscriptions.create(user: current_user, role: :athlete).save
    render :show
  end

  def unsubscribe
    @program.subscriptions.find_by(user: current_user).destroy
    render :show
  end

  private

  # Only allow a list of trusted parameters through.
  def program_params
    params.require(:program).permit(:name)
  end
end
