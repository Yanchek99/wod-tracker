require 'test_helper'

module WorkoutExtraction
  class LlmParserTest < ActiveSupport::TestCase
    setup do
      @movement = movements(:thruster)
    end

    test 'builds an unsaved Workout from well-formed shape and exercise-detail responses' do
      stub_two_call_response(
        shape: {
          extractable: true, name: 'Fran', score_type: 'time', rounds: nil, time: nil, interval: '21-15-9',
          time_cap: nil, ladder_step: nil, team_size: nil, notes: nil, gap_reason: nil, segments: [],
          exercise_snippets: [{ text: 'Thrusters (95/65)', segment_index: nil }]
        },
        exercises: [exercise_payload(movement_name: @movement.name, reps: 1, female_load: 65, male_load: 95)]
      )

      workout = WorkoutExtraction::LlmParser.call('21-15-9 Thrusters (95/65)')

      assert_not workout.persisted?
      assert_equal 'Fran', workout.name
      assert_equal 'time', workout.score_type
      assert_equal 1, workout.exercises.size
      assert_equal @movement, workout.exercises.first.movement
    end

    test 'builds segments and top-level exercises without colliding positions' do
      pull_up = movements(:pullup)

      stub_two_call_response(
        shape: {
          extractable: true, name: 'Part A + Extra', score_type: 'time', rounds: nil, time: nil, interval: nil,
          time_cap: nil, ladder_step: nil, team_size: nil, notes: nil, gap_reason: nil,
          segments: [{ name: 'Part A', rounds: nil, time_seconds: nil, interval_scheme: nil, rest_seconds: nil, notes: nil }],
          exercise_snippets: [
            { text: '10 Pull-ups', segment_index: 0 },
            { text: '20 Thrusters', segment_index: nil }
          ]
        },
        exercises: [
          exercise_payload(movement_name: pull_up.name, reps: 10),
          exercise_payload(movement_name: @movement.name, reps: 20)
        ]
      )

      workout = WorkoutExtraction::LlmParser.call('Part A: 10 Pull-ups\n20 Thrusters')

      assert workout.valid?
      assert_not workout.persisted?

      segment = workout.segments.first
      segment_exercise = workout.exercises.find { |exercise| exercise.segment == segment }
      top_level_exercise = workout.exercises.find { |exercise| exercise.segment.blank? }

      assert_not_equal segment.position, top_level_exercise.position
      assert_equal segment, segment_exercise.segment
      assert top_level_exercise.segment.blank?
    end

    test 'parses exercise details even when wrapped in a markdown code fence' do
      stub_request(:post, 'https://api.anthropic.com/v1/messages').to_return(
        anthropic_http_response(
          extractable: true, name: 'Fran', score_type: 'time', rounds: nil, time: nil, interval: nil,
          time_cap: nil, ladder_step: nil, team_size: nil, notes: nil, gap_reason: nil, segments: [],
          exercise_snippets: [{ text: 'Thrusters (95/65)', segment_index: nil }]
        ),
        anthropic_http_response_with_raw_text(
          "```json\n#{{ exercises: [exercise_payload(movement_name: @movement.name, reps: 1)] }.to_json}\n```"
        )
      )

      workout = WorkoutExtraction::LlmParser.call('21-15-9 Thrusters (95/65)')

      assert_equal 1, workout.exercises.size
      assert_equal @movement, workout.exercises.first.movement
    end

    private

    # Stubs the two sequential calls LlmParser makes: the workout-shape call, then (only if the shape
    # includes exercise_snippets) the exercise-details call. WebMock serves stubbed responses to the
    # same URL in the order given, matching LlmParser's fixed call order.
    def stub_two_call_response(shape:, exercises: nil)
      payloads = [shape]
      payloads << { exercises: exercises } if exercises

      stub_request(:post, 'https://api.anthropic.com/v1/messages').to_return(*payloads.map { |payload| anthropic_http_response(payload) })
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
