require "test_helper"

class WodExtraction::LlmParserTest < ActiveSupport::TestCase
  setup do
    @movement = movements(:thruster)
  end

  test "builds an unsaved Workout from a well-formed API response" do
    stub_anthropic_response(
      name: "Fran",
      score_type: "time",
      rounds: nil,
      time: nil,
      interval: "21-15-9",
      time_cap: nil,
      ladder_step: nil,
      team_size: nil,
      notes: nil,
      segments: [],
      exercises: [
        { movement_name: @movement.name, position: 1, reps: 1, load: nil, female_load: 65, male_load: 95,
          duration_seconds: nil, implement_count: nil, distance: nil, female_distance: nil,
          male_distance: nil, distance_unit: nil, distance_units_per_rep: nil, calories: nil,
          female_calories: nil, male_calories: nil, ladder_step_every: nil, ladder_exempt: nil,
          notes: nil }
      ]
    )

    workout = WodExtraction::LlmParser.call("21-15-9 Thrusters (95/65) Pull-ups")

    assert_not workout.persisted?
    assert_equal "Fran", workout.name
    assert_equal "time", workout.score_type
    assert_equal 1, workout.exercises.size
    assert_equal @movement, workout.exercises.first.movement
  end

  test "raises ExtractionError when a movement name doesn't resolve" do
    stub_anthropic_response(
      name: "Unknown Move WOD", score_type: "time", rounds: nil, time: nil, interval: nil,
      time_cap: nil, ladder_step: nil, team_size: nil, notes: nil, segments: [],
      exercises: [
        { movement_name: "Not A Real Movement", position: 1, reps: 10, load: nil,
          female_load: nil, male_load: nil, duration_seconds: nil, implement_count: nil,
          distance: nil, female_distance: nil, male_distance: nil, distance_unit: nil,
          distance_units_per_rep: nil, calories: nil, female_calories: nil,
          male_calories: nil, ladder_step_every: nil, ladder_exempt: nil, notes: nil }
      ]
    )

    assert_raises(WodExtraction::LlmParser::ExtractionError) do
      WodExtraction::LlmParser.call("10 Not A Real Movement")
    end
  end

  test "raises ExtractionError on API failure" do
    stub_request(:post, "https://api.anthropic.com/v1/messages")
      .to_return(status: 429, body: { type: "error", error: { type: "rate_limit_error", message: "slow down" } }.to_json)

    assert_raises(WodExtraction::LlmParser::ExtractionError) do
      WodExtraction::LlmParser.call("any text")
    end
  end

  private

  def stub_anthropic_response(payload)
    tool_call_id = "toolu_stub_001"
    stub_request(:post, "https://api.anthropic.com/v1/messages")
      .to_return(
        status: 200,
        headers: { "Content-Type" => "application/json" },
        body: {
          id: "msg_stub_001",
          type: "message",
          role: "assistant",
          model: "claude-haiku-4-5",
          content: [{ type: "text", text: payload.to_json }],
          stop_reason: "end_turn",
          usage: { input_tokens: 100, output_tokens: 50 }
        }.to_json
      )
  end
end
