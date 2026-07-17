require 'test_helper'

module WorkoutExtraction
  class LlmParserErrorTest < ActiveSupport::TestCase
    DATE = Date.new(2026, 1, 15)

    setup do
      @movement = movements(:thruster)
    end

    test "raises ExtractionError when a movement name doesn't resolve" do
      stub_llm_response(
        extractable: true, name: 'Unknown Move workout', score_type: 'time', rounds: nil, time: nil,
        interval: nil, time_cap: nil, ladder_step: nil, team_size: nil, notes: nil, gap_reason: nil,
        segments: [], exercises: [exercise_payload(movement_name: 'Not A Real Movement', reps: 10)]
      )

      assert_raises(WorkoutExtraction::LlmParser::ExtractionError) do
        WorkoutExtraction::LlmParser.call('10 Not A Real Movement', date: DATE)
      end
    end

    test 'raises ExtractionError when the LLM outputs an invalid enum value' do
      stub_llm_response(
        extractable: true, name: 'Bad Unit', score_type: 'time', rounds: nil, time: nil, interval: nil,
        time_cap: nil, ladder_step: nil, team_size: nil, notes: nil, gap_reason: nil, segments: [],
        exercises: [exercise_payload(movement_name: @movement.name, distance: 1609, distance_unit: 'mile')]
      )

      assert_raises(WorkoutExtraction::LlmParser::ExtractionError) do
        WorkoutExtraction::LlmParser.call('1 mile run', date: DATE)
      end
    end

    test 'raises UnrepresentableWorkoutError with the gap reason when the LLM declines to extract' do
      stub_llm_response(
        extractable: false, gap_reason: 'no movement in the catalog resembles "quantum burpees"',
        name: nil, score_type: nil, rounds: nil, time: nil, interval: nil, time_cap: nil,
        ladder_step: nil, team_size: nil, notes: nil, segments: [], exercises: []
      )

      error = assert_raises(WorkoutExtraction::LlmParser::UnrepresentableWorkoutError) do
        WorkoutExtraction::LlmParser.call('50 quantum burpees for time', date: DATE)
      end

      assert_equal 'no movement in the catalog resembles "quantum burpees"', error.message
    end

    test 'raises ExtractionError on API failure' do
      stub_request(:post, 'https://api.anthropic.com/v1/messages')
        .to_return(status: 429, body: { type: 'error', error: { type: 'rate_limit_error', message: 'slow down' } }.to_json)

      assert_raises(WorkoutExtraction::LlmParser::ExtractionError) do
        WorkoutExtraction::LlmParser.call('any text', date: DATE)
      end
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
