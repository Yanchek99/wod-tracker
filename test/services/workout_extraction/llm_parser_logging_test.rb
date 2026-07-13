require 'test_helper'

module WorkoutExtraction
  class LlmParserLoggingTest < ActiveSupport::TestCase
    DATE = Date.new(2026, 1, 15)

    setup do
      @movement = movements(:thruster)
    end

    test 'logs progress through the call when a logger is given' do
      stub_llm_response(
        extractable: true, name: 'Fran', score_type: 'time', rounds: nil, time: nil, interval: '21-15-9',
        time_cap: nil, ladder_step: nil, team_size: nil, notes: nil, gap_reason: nil, segments: [],
        exercises: [exercise_payload(movement_name: @movement.name, reps: 1)]
      )
      logged = StringIO.new
      logger = Logger.new(logged)

      WorkoutExtraction::LlmParser.call('21-15-9 Thrusters (95/65)', date: DATE, logger: logger)

      assert_includes logged.string, 'Fetching workout...'
      assert_includes logged.string, 'Workout received: extractable=true, segments=0, exercises=1'
    end

    test 'logs nothing when no logger is given' do
      stub_llm_response(
        extractable: true, name: 'Fran', score_type: 'time', rounds: nil, time: nil, interval: '21-15-9',
        time_cap: nil, ladder_step: nil, team_size: nil, notes: nil, gap_reason: nil, segments: [],
        exercises: [exercise_payload(movement_name: @movement.name, reps: 1)]
      )

      assert_nothing_raised { WorkoutExtraction::LlmParser.call('21-15-9 Thrusters (95/65)', date: DATE) }
    end

    private

    def stub_llm_response(payload)
      stub_request(:post, 'https://api.anthropic.com/v1/messages').to_return(anthropic_http_response(payload))
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
