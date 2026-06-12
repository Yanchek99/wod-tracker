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
    @log = @workout.logs.build(score_type: @workout.log_metric_measurement)
    @log.build_movement_logs
  end

  # GET /logs/1/edit
  def edit
    @workout = @log.workout
  end

  # POST /logs
  # POST /logs.json
  def create
    @log = @workout.logs.build(log_params)

    respond_to do |format|
      if @log.save
        format.html { redirect_to @log, notice: t('.notice') }
        format.json { render :show, status: :created, location: @log }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @log.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /logs/1
  # PATCH/PUT /logs/1.json
  def update
    @workout = @log.workout

    respond_to do |format|
      if @log.update(log_params)
        format.html { redirect_to @log, notice: t('.notice') }
        format.json { render :show, status: :ok, location: @log }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @log.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /logs/1
  # DELETE /logs/1.json
  def destroy
    @log.destroy
    respond_to do |format|
      format.html { redirect_to workout_url(@log.workout), notice: t('.notice') }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_log
    @log = Current.user.logs.find(params.expect(:id))
  end

  def set_workout
    @workout = Workout.find(params.expect(:workout_id))
  end

  # Only allow a list of trusted parameters through.
  def log_params
    params.expect(log: [
                    :score_type,
                    :score_value,
                    {
                      movement_logs_attributes: [[
                        :id,
                        :movement_id,
                        { metrics_attributes: [[:id, :measurement, :value, :_destroy]] }
                      ]]
                    }
                  ])
  end
end
