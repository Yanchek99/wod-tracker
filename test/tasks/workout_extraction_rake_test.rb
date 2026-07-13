require 'test_helper'
require 'rake'

class WorkoutExtractionRakeTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task['workout_extraction:parse'].reenable
  end

  test 'parses pasted stdin text into a Workout and prints it' do
    movement = movements(:thruster)
    stub_two_call_response(
      shape: {
        extractable: true, name: 'Fran', score_type: 'time', rounds: nil, time: nil, interval: '21-15-9',
        time_cap: nil, ladder_step: nil, team_size: nil, notes: nil, gap_reason: nil, segments: [],
        exercise_snippets: [{ text: 'Thrusters (95/65)', segment_index: nil }]
      },
      exercises: [
        { movement_name: movement.name, reps: 1, load: nil, female_load: 65, male_load: 95,
          duration_seconds: nil, implement_count: nil, distance: nil, female_distance: nil,
          male_distance: nil, distance_unit: nil, distance_units_per_rep: nil, calories: nil,
          female_calories: nil, male_calories: nil, ladder_step_every: nil, ladder_exempt: nil }
      ]
    )

    output = with_stdin('21-15-9 Thrusters (95/65)') { capture_io { Rake::Task['workout_extraction:parse'].invoke }.join }

    assert_includes output, 'name: "Fran"'
  end

  test 'aborts with a usage message when stdin is blank' do
    error = with_stdin('') { assert_raises(SystemExit) { Rake::Task['workout_extraction:parse'].invoke } }

    assert_equal 1, error.status
  end

  test 'aborts with the extraction error message on API failure' do
    stub_request(:post, 'https://api.anthropic.com/v1/messages')
      .to_return(status: 429, body: { type: 'error', error: { type: 'rate_limit_error', message: 'slow down' } }.to_json)

    error = with_stdin('any text') { assert_raises(SystemExit) { Rake::Task['workout_extraction:parse'].invoke } }

    assert_equal 1, error.status
  end

  test 'aborts with the gap reason when the LLM declines to extract' do
    stub_two_call_response(
      shape: {
        extractable: false, gap_reason: 'no movement in the catalog resembles "quantum burpees"',
        name: nil, score_type: nil, rounds: nil, time: nil, interval: nil, time_cap: nil,
        ladder_step: nil, team_size: nil, notes: nil, segments: [], exercise_snippets: []
      }
    )

    error = with_stdin('50 quantum burpees for time') do
      assert_raises(SystemExit) { Rake::Task['workout_extraction:parse'].invoke }
    end

    assert_equal 1, error.status
  end

  private

  def with_stdin(text)
    original_stdin = $stdin
    $stdin = StringIO.new(text)
    yield
  ensure
    $stdin = original_stdin
  end

  # Stubs the two sequential calls LlmParser makes: the workout-shape call, then (only if the shape
  # includes exercise_snippets) the exercise-details call. WebMock serves stubbed responses to the
  # same URL in the order given, matching LlmParser's fixed call order.
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
end
