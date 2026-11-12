require 'test_helper'

class IntendedStimulusBackfillTest < ActiveSupport::TestCase
  setup do
    @pending = workout_with_notes('Pending Stimulus')
  end

  test 'dry run counts targets and calls no parser' do
    result = IntendedStimulusBackfill.call(dry_run: true)

    assert_equal 1, result.targeted
    assert_equal 0, result.extracted
    assert_not_requested :post, 'https://api.anthropic.com/v1/messages'
    assert_nil @pending.reload.stimulus_source
  end

  test 'extracts pending workouts and stamps them extracted' do
    stub_stimulus_response(range_high: 300, movements: [])

    result = IntendedStimulusBackfill.call

    assert_equal [1, 1, 0], [result.targeted, result.extracted, result.failed]
    assert_equal [300, 'extracted'], @pending.reload.values_at(:stimulus_range_high, :stimulus_source)
  end

  test 'skips authored rows' do
    @pending.update!(stimulus_source: :authored)

    assert_equal 0, IntendedStimulusBackfill.call(dry_run: true).targeted
    assert_equal 0, IntendedStimulusBackfill.targets(force: true).count
  end

  test 'rerun is a no-op' do
    stub_stimulus_response(movements: [])
    IntendedStimulusBackfill.call

    assert_equal 0, IntendedStimulusBackfill.call.targeted
  end

  test 'force includes already extracted rows' do
    @pending.update!(stimulus_source: :extracted)

    assert_equal 0, IntendedStimulusBackfill.targets.count
    assert_equal [@pending], IntendedStimulusBackfill.targets(force: true).to_a
  end

  test 'a parser failure on one workout is counted and does not stop the rest' do
    workout_with_notes('Broken Stimulus', notes: 'This prose breaks the model.')
    stub_request(:post, 'https://api.anthropic.com/v1/messages')
      .with(body: /This prose breaks the model/).to_return(status: 500)
    stub_request(:post, 'https://api.anthropic.com/v1/messages')
      .with(body: /Keep it fast/).to_return(anthropic_body(movements: []))

    result = IntendedStimulusBackfill.call

    assert_equal [2, 1, 1], [result.targeted, result.extracted, result.failed]
  end

  private

  def workout_with_notes(name, notes: 'Keep it fast.')
    Workout.create!(name:, score_type: :time, intended_stimulus_notes: notes)
  end

  def stub_stimulus_response(payload)
    stub_request(:post, 'https://api.anthropic.com/v1/messages').to_return(anthropic_body(payload))
  end

  def anthropic_body(payload)
    { status: 200, headers: { 'Content-Type' => 'application/json' }, body: {
      id: 'msg_x', type: 'message', role: 'assistant', model: 'claude-haiku-4-5',
      content: [{ type: 'text', text: payload.to_json }], stop_reason: 'end_turn',
      usage: { input_tokens: 100, output_tokens: 50 }
    }.to_json }
  end
end
