require 'test_helper'

module WorkoutExtraction
  class LlmParserLoggingTest < ActiveSupport::TestCase
    setup do
      @movement = movements(:thruster)
    end

    test 'logs progress through both calls when a logger is given, to distinguish which call is in flight' do
      stub_two_call_response(
        shape: {
          extractable: true, name: 'Fran', score_type: 'time', rounds: nil, time: nil, interval: '21-15-9',
          time_cap: nil, ladder_step: nil, team_size: nil, notes: nil, gap_reason: nil, segments: [],
          exercise_snippets: [{ text: 'Thrusters (95/65)', segment_index: nil }]
        },
        exercises: [exercise_payload(movement_name: @movement.name, reps: 1)]
      )
      logged = StringIO.new
      logger = Logger.new(logged)

      WorkoutExtraction::LlmParser.call('21-15-9 Thrusters (95/65)', logger: logger)

      assert_includes logged.string, 'Fetching workout shape...'
      assert_includes logged.string, 'Workout shape received: extractable=true, segments=0, exercise_snippets=1'
      assert_includes logged.string, 'Fetching exercise details for 1 snippet(s)...'
      assert_includes logged.string, 'Exercise details received: 1 entries'
    end

    test 'logs nothing when no logger is given' do
      stub_two_call_response(
        shape: {
          extractable: true, name: 'Fran', score_type: 'time', rounds: nil, time: nil, interval: '21-15-9',
          time_cap: nil, ladder_step: nil, team_size: nil, notes: nil, gap_reason: nil, segments: [],
          exercise_snippets: [{ text: 'Thrusters (95/65)', segment_index: nil }]
        },
        exercises: [exercise_payload(movement_name: @movement.name, reps: 1)]
      )

      assert_nothing_raised { WorkoutExtraction::LlmParser.call('21-15-9 Thrusters (95/65)') }
    end

    private

    def stub_two_call_response(shape:, exercises: nil)
      payloads = [shape]
      payloads << { exercises: exercises } if exercises

      stub_request(:post, 'https://api.anthropic.com/v1/messages').to_return(*payloads.map { |payload| anthropic_http_response(payload) })
    end

    def anthropic_http_response(payload)
      {
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
end
