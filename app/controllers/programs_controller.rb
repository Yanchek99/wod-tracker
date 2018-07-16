class ProgramsController < ApplicationController
  before_action :set_program, only: [:show, :subscribe]

  def index
    @programs = Program.all.order(:name)
  end

  def show; end

  def subscribe
    @program.subscriptions.create(user: current_user).save
    render :show
  end

  private

  def set_program
    @program = Program.find(params[:id])
  end
end
