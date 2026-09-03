class WorkoutsController < ApplicationController
  LOAD_FIELDS = %i[load female_load male_load].freeze
  WORKOUT_STIMULUS_FIELDS = %i[stimulus_range_low stimulus_range_high].freeze
  EXERCISE_STIMULUS_FIELDS = %i[stimulus_loading stimulus_sets_max stimulus_duration_max].freeze

  before_action :set_workout, only: [:show, :edit, :edit_unstructured, :re_extract, :update, :destroy]

  # GET /workouts
  # GET /workouts.json
  def index
    @workouts = Workout.search_by_name(params[:query]).order(created_at: :desc).page(params[:page])
    @logged_workout_ids = logged_workout_ids_for(@workouts)
  end

  # GET /workouts/1
  # GET /workouts/1.json
  def show; end

  # GET /workouts/new
  def new
    @workout = Workout.new
    @workout.segments.build(position: 1)
  end

  # GET /workouts/new_unstructured
  def new_unstructured
    @workout = Workout.new
  end

  # POST /workouts/extract
  def extract
    @workout = WorkoutExtraction::LlmParser.call(params.expect(:wod_text), date: Date.current)
    render :new
  rescue WorkoutExtraction::LlmParser::ExtractionError,
         WorkoutExtraction::LlmParser::UnrepresentableWorkoutError => e
    @wod_text = params[:wod_text]
    @workout = Workout.new
    flash.now[:alert] = t('.extraction_failed', error: e.message)
    render :new_unstructured, status: :unprocessable_content
  end

  # GET /workouts/1/edit
  def edit; end

  # GET /workouts/1/edit_unstructured
  def edit_unstructured; end

  # PATCH /workouts/1/re_extract
  def re_extract
    extracted = WorkoutExtraction::LlmParser.call(params.expect(:wod_text), date: Date.current)
    @workout.replace_with_extraction!(extracted)
    render :edit
  rescue WorkoutExtraction::LlmParser::ExtractionError,
         WorkoutExtraction::LlmParser::UnrepresentableWorkoutError => e
    @wod_text = params[:wod_text]
    flash.now[:alert] = t('.extraction_failed', error: e.message)
    render :edit_unstructured, status: :unprocessable_content
  end

  # POST /workouts
  # POST /workouts.json
  def create
    @workout = Workout.new(workout_params)
    respond_to do |format|
      if @workout.save
        @workout = @workout.absorb_duplicate!
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

      @workout = @workout.absorb_duplicate!
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
    @workout = Workout.includes(segments: :exercises).find(params.expect(:id))
  end

  def logged_workout_ids_for(workouts)
    Current.user.logs.where(workout_id: workouts.map(&:id)).distinct.pluck(:workout_id)
  end

  # Only allow a list of trusted parameters through.
  def workout_params
    exercise_params = [:id, :movement_id, :position, :distance_units_per_rep, :_destroy,
                       :reps, :duration_seconds, :ladder_step_every, :ladder_exempt,
                       :load, :female_load, :male_load, :implement_count,
                       :distance, :female_distance, :male_distance, :distance_unit,
                       :calories, :female_calories, :male_calories, :notes,
                       *EXERCISE_STIMULUS_FIELDS]

    attributes = params.expect(workout: [:name, :notes, :time_cap, :score_type, :ladder_step, :team_size,
                                         :intended_stimulus_notes, *WORKOUT_STIMULUS_FIELDS,
                                         { segments_attributes: [[:id, :name, :rounds, :time_seconds, :interval_scheme,
                                                                  :rest_seconds, :notes, :position, :_destroy,
                                                                  { exercises_attributes: [exercise_params] }]] }])
    canonicalize_submitted_loads(attributes)
    stamp_authored_stimulus(attributes)
    attributes
  end

  # A stimulus value that comes in through the form is coach-authored. Stamp the row's source
  # so a later importer/model run treats it as an override rather than something to refill.
  def stamp_authored_stimulus(attributes)
    attributes[:stimulus_source] = :authored if stimulus_present?(attributes, WORKOUT_STIMULUS_FIELDS)

    submitted_exercise_attributes(attributes).each do |exercise|
      exercise[:stimulus_source] = :authored if stimulus_present?(exercise, EXERCISE_STIMULUS_FIELDS)
    end
  end

  def stimulus_present?(attrs, fields)
    fields.any? { |field| attrs[field].present? }
  end

  # Loads are stored canonically in pounds. A metric athlete enters kilograms, so normalize the
  # submitted load values before they reach the model; imperial input is already canonical.
  def canonicalize_submitted_loads(attributes)
    unit = Current.user.load_display_unit
    return if unit == :lb

    submitted_exercise_attributes(attributes).each do |exercise|
      LOAD_FIELDS.each do |field|
        value = exercise[field]
        exercise[field] = LoadEquivalence.to_lb(value.to_i, unit) if value.present?
      end
    end
  end

  def submitted_exercise_attributes(attributes)
    nested_children(attributes[:segments_attributes])
      .flat_map { |segment| nested_children(segment[:exercises_attributes]) }
  end

  # Nested attributes arrive either as an array or as a "0","1",... keyed hash
  # (fields_for's default, and what a real form submits); normalize both to the
  # list of child param hashes so callers can iterate and mutate them.
  def nested_children(nested)
    return [] if nested.blank?

    nested.respond_to?(:values) ? nested.values : nested
  end
end
