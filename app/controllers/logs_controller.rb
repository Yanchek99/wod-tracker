class LogsController < ApplicationController
  before_action :set_workout, only: [:index, :new, :create]
  before_action :set_log, only: [:show, :edit, :update, :destroy]

  # GET /logs
  # GET /logs.json
  def index
    @logs = Current.user.logs
  end

  # GET /logs/1
  # GET /logs/1.json
  def show; end

  # GET /logs/new
  def new
    @log = @workout.logs.build
    @log.build_metric(measurement: @workout.metric.measurement)
    @log.build_movement_logs
  end

  # GET /logs/1/edit
  def edit; end

  # POST /logs
  # POST /logs.json
  def create
    @log = @workout.logs.build(log_params)

    respond_to do |format|
      if @log.save
        format.html { redirect_to @log, notice: t('.create.notice') }
        format.json { render :show, status: :created, location: @log }
      else
        format.html { render :new }
        format.json { render json: @log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /logs/1
  # PATCH/PUT /logs/1.json
  def update
    respond_to do |format|
      if @log.update(log_params)
        format.html { redirect_to @log, notice: t('.update.notice') }
        format.json { render :show, status: :ok, location: @log }
      else
        format.html { render :edit }
        format.json { render json: @log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /logs/1
  # DELETE /logs/1.json
  def destroy
    @log.destroy
    respond_to do |format|
      format.html { redirect_to workout_url(@log.workout), notice: t('.destroy.notice') }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_log
    @log = Log.find(params[:id])
  end

  def set_workout
    @workout = Workout.find(params[:workout_id])
  end

  # Only allow a list of trusted parameters through.
  def log_params
    params.require(:log).permit(movement_logs_attributes: [
                                  :id,
                                  :movement_id,
                                  { metrics_attributes: [:id, :measurement, :value, :_destroy] }
                                ],
                                metric_attributes: [:id, :measurement, :value])
  end
end
