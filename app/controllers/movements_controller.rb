class MovementsController < ApplicationController
  # GET /workouts
  # GET /workouts.json
  def index
    @movements = Movement.search_by_name(params[:query]).order(name: :desc).limit(10)
    respond_to do |format|
      format.json { render json: @movements, status: :ok }
    end
  end

  # POST /movements
  # POST /movements.json
  def create
    @movement = Movement.new(movement_params)
    respond_to do |format|
      if @movement.save
        format.json { render json: @movement, status: :created }
      else
        format.json { render json: @movement.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def movement_params
    params.require(:movement).permit(:name)
  end
end
