class WorkoutsController < ApplicationController
  before_action :set_workout, only: [:show, :edit, :update, :destroy]

  # GET /workouts
  # GET /workouts.json
  def index
    @workouts = Workout.search_by_name(params[:query]).order(created_at: :desc)
  end

  # GET /workouts/1
  # GET /workouts/1.json
  def show; end

  # GET /workouts/new
  def new
    @workout = Workout.new
  end

  # GET /workouts/1/edit
  def edit; end

  # POST /workouts
  # POST /workouts.json
  def create
    @workout = Workout.new(workout_params)
    respond_to do |format|
      if @workout.save
        format.html { redirect_to @workout, notice: t('.notice') }
        format.json { render :show, status: :created, location: @workout }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @workout.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /workouts/1
  # PATCH/PUT /workouts/1.json
  def update
    attributes = workout_params
    updated = false

    @workout.transaction do
      @workout.reserve_submitted_positions!(attributes)
      @workout.reload
      updated = @workout.update(attributes)
      raise ActiveRecord::Rollback unless updated
    end

    respond_to do |format|
      if updated
        format.html { redirect_to @workout, notice: t('.notice') }
        format.json { render :show, status: :ok, location: @workout }
      else
        format.html { render :edit }
        format.json { render json: @workout.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /workouts/1
  # DELETE /workouts/1.json
  def destroy
    @workout.destroy
    respond_to do |format|
      format.html { redirect_to workouts_url, notice: t('.notice') }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_workout
    @workout = Workout.includes(:exercises).find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def workout_params
    exercise_params = [:id, :movement_id, :position, :distance_units_per_rep, :_destroy,
                       :reps, :duration_seconds,
                       :load, :female_load, :male_load, :load_unit, :implement_count,
                       :distance, :female_distance, :male_distance, :distance_unit,
                       :calories, :female_calories, :male_calories, :notes]

    params.expect(workout: [:name, :rounds, :time, :interval, :notes, :time_cap,
                            :score_type,
                            { segments_attributes: [[:id, :name, :rounds, :time_seconds, :interval_scheme,
                                                     :rest_seconds, :notes, :position, :_destroy,
                                                     { exercises_attributes: [exercise_params] }]] },
                            { exercises_attributes: [exercise_params] }])
  end
end
