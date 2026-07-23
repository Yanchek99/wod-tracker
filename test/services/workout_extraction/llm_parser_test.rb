require 'test_helper'

module WorkoutExtraction
  class LlmParserTest < ActiveSupport::TestCase
    DATE = Date.new(2026, 1, 15)

    setup do
      @movement = movements(:thruster)
    end

    # Exercises are built via `segment.exercises.build(...)`, not `workout.exercises.build(...)` --
    # a has_many :through :segments association can't autosave records added directly to its own
    # in-memory collection, so `workout.exercises` stays empty on an unsaved workout (see
    # CfWod::WorkoutParserTest, which hit the same thing first). Read exercises via each segment.
    def workout_exercises(workout) = workout.segments.flat_map(&:exercises)

    test 'builds an unsaved Workout from a well-formed response' do
      stub_llm_response(
        extractable: true, name: 'Fran', score_type: 'time', rounds: nil, time: nil, interval: '21-15-9',
        time_cap: nil, ladder_step: nil, team_size: nil, notes: nil, gap_reason: nil, segments: [],
        exercises: [exercise_payload(movement_name: @movement.name, reps: 1, female_load: 65, male_load: 95)]
      )

      workout = WorkoutExtraction::LlmParser.call('21-15-9 Thrusters (95/65)', date: DATE)

      assert_not workout.persisted?
      assert_equal 'Fran', workout.name
      assert_equal 'time', workout.score_type
      assert_equal 1, workout_exercises(workout).size
      assert_equal @movement, workout_exercises(workout).first.movement
    end

    test 'falls back to a date-based name when the LLM omits one' do
      stub_llm_response(
        extractable: true, name: nil, score_type: 'time', rounds: nil, time: nil, interval: nil,
        time_cap: nil, ladder_step: nil, team_size: nil, notes: nil, gap_reason: nil, segments: [],
        exercises: [exercise_payload(movement_name: @movement.name, reps: 20)]
      )

      workout = WorkoutExtraction::LlmParser.call('20 Thrusters for time', date: DATE)

      assert_equal 'CF-260115', workout.name
    end

    test 'wraps a flat workout in one implicit unnamed segment carrying its scheme' do
      stub_llm_response(
        extractable: true, name: 'Cindy', score_type: 'round', rounds: nil, time: 1200, interval: nil,
        time_cap: nil, ladder_step: nil, team_size: nil, notes: nil, gap_reason: nil, segments: [],
        exercises: [exercise_payload(movement_name: @movement.name, reps: 20)]
      )

      workout = WorkoutExtraction::LlmParser.call('AMRAP 20: 20 Thrusters', date: DATE)

      assert workout.valid?
      assert_equal 1, workout.segments.size
      segment = workout.segments.first
      assert_nil segment.name
      assert_equal 1200, segment.time_seconds
      assert_equal 1, segment.exercises.size
      assert_equal @movement, segment.exercises.first.movement
    end

    test 'wraps top-level exercises in an implicit segment positioned after any named segments' do
      pull_up = movements(:pullup)

      stub_llm_response(
        extractable: true, name: 'Part A + Extra', score_type: 'time', rounds: nil, time: nil, interval: nil,
        time_cap: nil, ladder_step: nil, team_size: nil, notes: nil, gap_reason: nil,
        segments: [
          { name: 'Part A', rounds: nil, time_seconds: nil, interval_scheme: nil, rest_seconds: nil, notes: nil,
            exercises: [exercise_payload(movement_name: pull_up.name, reps: 10)] }
        ],
        exercises: [exercise_payload(movement_name: @movement.name, reps: 20)]
      )

      workout = WorkoutExtraction::LlmParser.call('Part A: 10 Pull-ups\n20 Thrusters', date: DATE)

      assert workout.valid?
      assert_not workout.persisted?
      assert_equal 2, workout.segments.size

      named_segment, implicit_segment = workout.segments.sort_by(&:position)
      assert_equal 'Part A', named_segment.name
      assert_nil implicit_segment.name
      assert_not_equal named_segment.position, implicit_segment.position
      assert_equal pull_up, named_segment.exercises.first.movement
      assert_equal @movement, implicit_segment.exercises.first.movement
    end

    test 'parses the response even when wrapped in a markdown code fence' do
      payload = {
        extractable: true, name: 'Fran', score_type: 'time', rounds: nil, time: nil, interval: nil,
        time_cap: nil, ladder_step: nil, team_size: nil, notes: nil, gap_reason: nil, segments: [],
        exercises: [exercise_payload(movement_name: @movement.name, reps: 1)]
      }
      stub_request(:post, 'https://api.anthropic.com/v1/messages')
        .to_return(anthropic_http_response_with_raw_text("```json\n#{payload.to_json}\n```"))

      workout = WorkoutExtraction::LlmParser.call('21-15-9 Thrusters (95/65)', date: DATE)

      assert_equal 1, workout_exercises(workout).size
      assert_equal @movement, workout_exercises(workout).first.movement
    end

    test 'uses the last fenced block when the model self-corrects with a second one' do
      draft = { extractable: true, name: 'Fran', score_type: 'time', segments: [],
                exercises: [exercise_payload(movement_name: 'wrong movement', reps: 1)] }
      corrected = { extractable: true, name: 'Fran', score_type: 'time', segments: [],
                    exercises: [exercise_payload(movement_name: @movement.name, reps: 1)] }
      raw_text = "```json\n#{draft.to_json}\n```\n\nWait, let me reconsider.\n\n```json\n#{corrected.to_json}\n```"
      stub_request(:post, 'https://api.anthropic.com/v1/messages')
        .to_return(anthropic_http_response_with_raw_text(raw_text))

      workout = WorkoutExtraction::LlmParser.call('21-15-9 Thrusters (95/65)', date: DATE)

      assert_equal 1, workout_exercises(workout).size
      assert_equal @movement, workout_exercises(workout).first.movement
    end

    test 'drops a stray sex-specific companion when a plain value is also set for the same dimension' do
      stub_llm_response(
        extractable: true, name: 'Row Ladder', score_type: 'time', segments: [],
        exercises: [exercise_payload(movement_name: @movement.name, calories: 1, female_calories: 21)]
      )

      workout = WorkoutExtraction::LlmParser.call('21-15-9 Calorie Row', date: DATE)

      exercise = workout_exercises(workout).first
      assert_equal 1, exercise.calories
      assert_nil exercise.female_calories
      assert_nil exercise.male_calories
    end

    test 'treats load-scored rep schemes as lifting sets, not intervals' do
      movement = Movement.find_or_create_by!(name: 'Power Clean')
      stub_llm_response(
        extractable: true, name: 'Power Clean Heavy Day', score_type: 'weight',
        rounds: nil, time: nil, interval: '3-3-2-2-1-1-1-1', segments: [],
        exercises: [exercise_payload(movement_name: movement.name, reps: 1)]
      )

      workout = WorkoutExtraction::LlmParser.call('Power clean 3-3-2-2-1-1-1-1 reps', date: DATE)

      segment = workout.segments.first
      assert_nil segment.interval_scheme
      assert_equal [3, 3, 2, 2, 1, 1, 1, 1], segment.exercises.map(&:reps)
      assert_equal [movement], segment.exercises.map(&:movement).uniq
    end

    test 'marks only barbell-family movements load-bearing in manually scored weight workouts' do
      barbell_movements = load_bearing_barbell_movements
      pull_up = movements(:pull_up)
      stub_llm_response(
        extractable: true, name: 'Open-style Complex', score_type: 'weight', rounds: nil, time: nil, interval: nil,
        segments: [],
        exercises: (barbell_movements + [pull_up]).map { |movement| exercise_payload(movement_name: movement.name, reps: 1) }
      )

      workout = WorkoutExtraction::LlmParser.call('Open-style Complex', date: DATE)

      assert workout.valid?
      assert_equal 'weight', workout.score_type
      assert_not workout.calculated_lifting_score?
      assert_loads_marked(workout, load_bearing: barbell_movements, non_load_bearing: [pull_up])
    end

    private

    def assert_loads_marked(workout, load_bearing:, non_load_bearing:)
      exercises = workout_exercises(workout).index_by { |exercise| exercise.movement.name }

      load_bearing.each { |movement| assert_equal 0, exercises.fetch(movement.name).load }
      non_load_bearing.each { |movement| assert_nil exercises.fetch(movement.name).load }
    end

    def load_bearing_barbell_movements
      [
        movements(:deadlift),
        Movement.find_or_create_by!(name: 'Clean'),
        Movement.find_or_create_by!(name: 'Hang Clean'),
        Movement.find_or_create_by!(name: 'Hang Power Snatch'),
        Movement.find_or_create_by!(name: 'Clean and Push Jerk'),
        Movement.find_or_create_by!(name: 'Ground to Overhead'),
        Movement.find_or_create_by!(name: 'Power Clean and Split Jerk'),
        Movement.find_or_create_by!(name: 'Shoulder Press'),
        Movement.find_or_create_by!(name: 'Snatch Balance')
      ]
    end

    def stub_llm_response(payload)
      stub_request(:post, 'https://api.anthropic.com/v1/messages').to_return(anthropic_http_response(payload))
    end

    def anthropic_http_response(payload)
      anthropic_http_response_with_raw_text(payload.to_json)
    end

    def anthropic_http_response_with_raw_text(text)
      {
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: {
          id: 'msg_stub_001',
          type: 'message',
          role: 'assistant',
          model: 'claude-haiku-4-5',
          content: [{ type: 'text', text: text }],
          stop_reason: 'end_turn',
          usage: { input_tokens: 100, output_tokens: 50 }
        }.to_json
      }
    end

    # A full EXERCISE_SCHEMA-shaped payload with every optional field nil except what's overridden --
    # keeps individual tests from having to spell out all 17 fields every time.
    def exercise_payload(overrides)
      {
        movement_name: nil, reps: nil, duration_seconds: nil, load: nil, female_load: nil, male_load: nil,
        implement_count: nil, distance: nil, female_distance: nil, male_distance: nil, distance_unit: nil,
        distance_units_per_rep: nil, calories: nil, female_calories: nil, male_calories: nil,
        ladder_step_every: nil, ladder_exempt: nil
      }.merge(overrides)
    end
  end
end
