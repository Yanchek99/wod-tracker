class ProgramsController < ApplicationController
  before_action :set_program, only: [:show, :subscribe, :unsubscribe]

  def index
    @programs = Program.all.order(:name)
  end

  def show; end

  def subscribe
    @program.subscriptions.create(user: current_user).save
    render :show
  end

  def unsubscribe
    @program.subscriptions.find_by(user: current_user).destroy
    render :show
  end

  private

  def set_program
    @program = Program.find(params[:id])
  end
end
