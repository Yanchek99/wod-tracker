require 'test_helper'

module WorkoutExtraction
  class LlmParserErrorTest < ActiveSupport::TestCase
    setup do
      @movement = movements(:thruster)
    end

    test "raises ExtractionError when a movement name doesn't resolve" do
      stub_two_call_response(
        shape: {
          extractable: true, name: 'Unknown Move workout', score_type: 'time', rounds: nil, time: nil,
          interval: nil, time_cap: nil, ladder_step: nil, team_size: nil, notes: nil, gap_reason: nil,
          segments: [], exercise_snippets: [{ text: '10 Not A Real Movement', segment_index: nil }]
        },
        exercises: [exercise_payload(movement_name: 'Not A Real Movement', reps: 10)]
      )

      assert_raises(WorkoutExtraction::LlmParser::ExtractionError) do
        WorkoutExtraction::LlmParser.call('10 Not A Real Movement')
      end
    end

    test 'raises ExtractionError when the exercise-details call returns a different count than the snippets' do
      stub_two_call_response(
        shape: {
          extractable: true, name: 'Mismatch', score_type: 'time', rounds: nil, time: nil, interval: nil,
          time_cap: nil, ladder_step: nil, team_size: nil, notes: nil, gap_reason: nil, segments: [],
          exercise_snippets: [
            { text: '10 Pull-ups', segment_index: nil },
            { text: '20 Thrusters', segment_index: nil }
          ]
        },
        exercises: [exercise_payload(movement_name: @movement.name, reps: 20)]
      )

      assert_raises(WorkoutExtraction::LlmParser::ExtractionError) do
        WorkoutExtraction::LlmParser.call('10 Pull-ups\n20 Thrusters')
      end
    end

    test 'raises UnrepresentableWorkoutError with the gap reason when the LLM declines to extract' do
      stub_two_call_response(
        shape: {
          extractable: false, gap_reason: 'no movement in the catalog resembles "quantum burpees"',
          name: nil, score_type: nil, rounds: nil, time: nil, interval: nil, time_cap: nil,
          ladder_step: nil, team_size: nil, notes: nil, segments: [], exercise_snippets: []
        }
      )

      error = assert_raises(WorkoutExtraction::LlmParser::UnrepresentableWorkoutError) do
        WorkoutExtraction::LlmParser.call('50 quantum burpees for time')
      end

      assert_equal 'no movement in the catalog resembles "quantum burpees"', error.message
    end

    test 'raises ExtractionError on API failure' do
      stub_request(:post, 'https://api.anthropic.com/v1/messages')
        .to_return(status: 429, body: { type: 'error', error: { type: 'rate_limit_error', message: 'slow down' } }.to_json)

      assert_raises(WorkoutExtraction::LlmParser::ExtractionError) do
        WorkoutExtraction::LlmParser.call('any text')
      end
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
