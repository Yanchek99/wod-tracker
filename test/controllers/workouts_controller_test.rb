require 'test_helper'

class WorkoutsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @workout = workouts(:fran)
    sign_in users(:mathew)
  end

  test 'should get index' do
    get workouts_url
    assert_response :success
  end

  test 'should get new' do
    get new_workout_url
    assert_response :success
    assert_select 'form.workout-form'
    assert_select 'textarea[name="wod_text"]', count: 0
  end

  test 'should get new unstructured' do
    get new_unstructured_workouts_url
    assert_response :success
    assert_select 'textarea[name="wod_text"]'
    assert_select 'form[action=?]', extract_workouts_path
  end

  test 'renders the textarea when the workout cannot be represented' do
    stub_unrepresentable_workout_response('unsupported workout')

    post extract_workouts_url, params: { wod_text: 'unsupported workout' }

    assert_response :unprocessable_content
    assert_equal "Couldn't understand that workout text (unsupported workout). Try rephrasing, or enter it manually.",
                 flash[:alert]
    assert_select 'textarea[name="wod_text"]', text: 'unsupported workout'
  end

  test 'renders manual form after extracting workout text' do
    stub_extractable_workout_response(name: 'Extracted Workout', movement_name: movements(:pullup).name)

    post extract_workouts_url, params: { wod_text: '10 pull-ups for time' }

    assert_response :success
    assert_select 'form.workout-form'
    assert_select 'input[name="workout[name]"][value="Extracted Workout"]'
  end

  test 'renders manual form when manual workout submission is invalid' do
    post workouts_url, params: { workout: { name: '', score_type: '' } }

    assert_response :unprocessable_content
    assert_select 'form.workout-form'
  end

  test 'should create workout' do
    assert_difference(['Workout.count', 'ActionText::RichText.count']) do
      post workouts_url, params: { workout: {
        name: @workout.name,
        notes: '<div>Use the prescribed loading.</div>',
        score_type: :round
      } }
    end

    assert_redirected_to workout_url(Workout.last)
    assert_equal 'round', Workout.last.score_type
    assert_equal 'Use the prescribed loading.', Workout.last.notes.to_plain_text.strip
  end

  test 'should create workout with direct exercise prescriptions' do
    assert_difference(['Workout.count', 'Exercise.count'], 1) do
      post workouts_url, params: { workout: {
        name: 'Nested Workout',
        score_type: :time,
        segments_attributes: {
          '0' => { position: 1, exercises_attributes: {
            '0' => { movement_id: movements(:pullup).id, position: 1, reps: 10 }
          } }
        }
      } }
    end

    assert_redirected_to workout_url(Workout.last)
    exercise = Workout.last.exercises.first
    assert_equal movements(:pullup), exercise.movement
    assert_equal 10, exercise.reps
  end

  test 'should create workout with sex-specific exercise prescriptions' do
    assert_difference(['Workout.count', 'Exercise.count'], 1) do
      post workouts_url, params: { workout: {
        name: 'Sex Specific Workout',
        score_type: :time,
        segments_attributes: {
          '0' => { position: 1, exercises_attributes: {
            '0' => { movement_id: movements(:thruster).id, position: 1, reps: 1, female_load: 65, male_load: 95 }
          } }
        }
      } }
    end

    exercise = Workout.last.exercises.first
    assert_nil exercise.load
    assert_equal 65, exercise.female_load
    assert_equal 95, exercise.male_load
    assert_predicate exercise, :load_bearing?
  end

  test 'should show workout' do
    get workout_url(@workout)
    assert_response :success
  end

  test 'does not repeat the governing segment scheme as its own header line' do
    get workout_url(@workout)

    assert_select 'p', text: '21-15-9 for time'
    assert_select 'li', text: '21-15-9 of', count: 0
  end

  test 'should get edit' do
    get edit_workout_url(@workout)
    assert_response :success
    assert_select 'trix-editor'
  end

  test 'should update workout' do
    patch workout_url(@workout), params: { workout: {
      name: @workout.name,
      notes: '<div>Break up the pull-ups early.</div>'
    } }

    assert_redirected_to workout_url(@workout)
    assert_equal 'Break up the pull-ups early.', @workout.reload.notes.to_plain_text.strip
  end

  test 'submitting a blank interval field keeps a timed-rounds segment timed-rounds' do
    workout = Workout.create!(name: 'Timed Rounds Update Test', score_type: :time)
    segment = workout.segments.create!(rounds: 4, time_seconds: 1500, position: 1)

    # The builder form always submits interval_scheme now (see _segment_fields.html.slim);
    # an unfilled interval field arrives as "" here, the same way a real form submission
    # would, not just via the client-side "Done" button's local JS state.
    patch workout_url(workout), params: { workout: {
      name: workout.name,
      score_type: workout.score_type,
      segments_attributes: {
        '0' => { id: segment.id, position: 1, rounds: 4, time_seconds: 1500, interval_scheme: '' }
      }
    } }

    assert_redirected_to workout_url(workout)
    segment.reload
    assert_predicate segment, :timed_rounds?
    assert_not_predicate segment, :interval?
  end

  test 'should destroy workout' do
    assert_difference('Workout.count', -1) do
      delete workout_url(@workout)
    end

    assert_redirected_to workouts_url
  end

  private

  def stub_extractable_workout_response(name:, movement_name:)
    stub_llm_response(
      extractable: true, gap_reason: nil, name: name, score_type: 'time', rounds: nil, time: nil,
      interval: nil, time_cap: nil, ladder_step: nil, team_size: nil, notes: nil, segments: [],
      exercises: [exercise_payload(movement_name: movement_name, reps: 10)]
    )
  end

  def stub_unrepresentable_workout_response(reason)
    stub_llm_response(unrepresentable_workout_payload(reason))
  end

  def stub_llm_response(payload)
    stub_request(:post, 'https://api.anthropic.com/v1/messages').to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: {
        id: 'msg_stub_001',
        type: 'message',
        role: 'assistant',
        model: 'claude-haiku-4-5',
        content: [{ type: 'text', text: payload.to_json }],
        stop_reason: 'end_turn',
        usage: { input_tokens: 100, output_tokens: 50 }
      }.to_json
    )
  end

  def unrepresentable_workout_payload(reason)
    {
      extractable: false, gap_reason: reason, name: nil, score_type: nil, rounds: nil, time: nil,
      interval: nil, time_cap: nil, ladder_step: nil, team_size: nil, notes: nil, segments: [], exercises: []
    }
  end

  def exercise_payload(overrides)
    {
      movement_name: nil, reps: nil, duration_seconds: nil, load: nil, female_load: nil, male_load: nil,
      implement_count: nil, distance: nil, female_distance: nil, male_distance: nil, distance_unit: nil,
      distance_units_per_rep: nil, calories: nil, female_calories: nil, male_calories: nil,
      ladder_step_every: nil, ladder_exempt: nil
    }.merge(overrides)
  end
end
