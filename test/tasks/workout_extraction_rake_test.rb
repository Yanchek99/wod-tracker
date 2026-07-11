require 'test_helper'
require 'rake'

class WorkoutExtractionRakeTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task['workout_extraction:parse'].reenable
  end

  test 'parses text into a Workout and prints it' do
    movement = movements(:thruster)
    stub_anthropic_response(
      name: 'Fran', score_type: 'time', rounds: nil, time: nil, interval: '21-15-9', time_cap: nil,
      ladder_step: nil, team_size: nil, notes: nil, segments: [],
      exercises: [
        { movement_name: movement.name, position: 1, reps: 1, load: nil, female_load: 65, male_load: 95,
          duration_seconds: nil, implement_count: nil, distance: nil, female_distance: nil,
          male_distance: nil, distance_unit: nil, distance_units_per_rep: nil, calories: nil,
          female_calories: nil, male_calories: nil, ladder_step_every: nil, ladder_exempt: nil, notes: nil }
      ]
    )

    output = capture_io { Rake::Task['workout_extraction:parse'].invoke('21-15-9 Thrusters (95/65) Pull-ups') }.join

    assert_includes output, 'name: "Fran"'
  end

  test 'aborts with a usage message when no text is given' do
    error = assert_raises(SystemExit) { Rake::Task['workout_extraction:parse'].invoke }

    assert_equal 1, error.status
  end

  test 'aborts with the extraction error message on API failure' do
    stub_request(:post, 'https://api.anthropic.com/v1/messages')
      .to_return(status: 429, body: { type: 'error', error: { type: 'rate_limit_error', message: 'slow down' } }.to_json)

    error = assert_raises(SystemExit) { Rake::Task['workout_extraction:parse'].invoke('any text') }

    assert_equal 1, error.status
  end

  private

  def stub_anthropic_response(payload)
    stub_request(:post, 'https://api.anthropic.com/v1/messages')
      .to_return(
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
end
