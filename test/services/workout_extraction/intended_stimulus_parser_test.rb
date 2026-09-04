require 'test_helper'

module WorkoutExtraction
  class IntendedStimulusParserTest < ActiveSupport::TestCase
    setup do
      @workout = Workout.create!(name: 'CF-Stimulus', score_type: :time,
                                 intended_stimulus_notes: 'Keep the thrusters unbroken; pull-ups in no more than 3 sets.')
      segment = @workout.segments.create!(interval_scheme: '21-15-9', position: 1)
      @thruster = segment.exercises.create!(movement: movements(:thruster), position: 1, reps: 1, load: 95)
      @pullup = segment.exercises.create!(movement: movements(:pullup), position: 2, reps: 1)
    end

    test 'fills the workout range and per-movement fields, tagged extracted' do
      stub_stimulus_response(
        range_low: 180, range_high: 300,
        movements: [
          { movement_name: 'Thruster', loading: 'moderate', sets_max: 1, duration_max_seconds: nil },
          { movement_name: 'Pull Up', loading: nil, sets_max: 3, duration_max_seconds: nil }
        ]
      )

      WorkoutExtraction::IntendedStimulusParser.call(@workout)

      assert_equal [180, 300, 'extracted'],
                   @workout.reload.values_at(:stimulus_range_low, :stimulus_range_high, :stimulus_source)
      assert_equal ['moderate', 1, 'extracted'],
                   @thruster.reload.values_at(:stimulus_loading, :stimulus_sets_max, :stimulus_source)
      assert_equal [3, 'extracted'], @pullup.reload.values_at(:stimulus_sets_max, :stimulus_source)
    end

    test 'sorts an inverted range from the model' do
      stub_stimulus_response(range_low: 320, range_high: 200, movements: [])

      WorkoutExtraction::IntendedStimulusParser.call(@workout)

      assert_equal [200, 320], @workout.reload.values_at(:stimulus_range_low, :stimulus_range_high)
    end

    test 'a lone ceiling sets only the high bound' do
      stub_stimulus_response(range_low: nil, range_high: 480, movements: [])

      WorkoutExtraction::IntendedStimulusParser.call(@workout)

      assert_nil @workout.reload.stimulus_range_low
      assert_equal 480, @workout.stimulus_range_high
    end

    test 'skips a movement name that is not in the workout' do
      stub_stimulus_response(
        range_low: nil, range_high: nil,
        movements: [{ movement_name: 'Rope Climb', loading: 'heavy', sets_max: nil, duration_max_seconds: nil }]
      )

      assert_nothing_raised { WorkoutExtraction::IntendedStimulusParser.call(@workout) }
      assert_nil @thruster.reload.stimulus_loading
    end

    test 'does not overwrite an authored exercise value' do
      @thruster.update!(stimulus_loading: :heavy, stimulus_source: :authored)
      stub_stimulus_response(
        range_low: nil, range_high: nil,
        movements: [{ movement_name: 'Thruster', loading: 'light', sets_max: nil, duration_max_seconds: nil }]
      )

      WorkoutExtraction::IntendedStimulusParser.call(@workout)

      assert_equal %w[heavy authored], @thruster.reload.values_at(:stimulus_loading, :stimulus_source)
    end

    test 'blank notes short-circuits without calling the model' do
      @workout.update!(intended_stimulus_notes: nil)

      assert_nil WorkoutExtraction::IntendedStimulusParser.call(@workout)
      assert_not_requested :post, 'https://api.anthropic.com/v1/messages'
    end

    test 'raises ExtractionError on malformed JSON' do
      stub_request(:post, 'https://api.anthropic.com/v1/messages')
        .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: {
          id: 'msg_x', type: 'message', role: 'assistant', model: 'claude-haiku-4-5',
          content: [{ type: 'text', text: 'not json' }], stop_reason: 'end_turn',
          usage: { input_tokens: 1, output_tokens: 1 }
        }.to_json)

      assert_raises(WorkoutExtraction::IntendedStimulusParser::ExtractionError) do
        WorkoutExtraction::IntendedStimulusParser.call(@workout)
      end
    end

    private

    def stub_stimulus_response(payload)
      stub_request(:post, 'https://api.anthropic.com/v1/messages')
        .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: {
          id: 'msg_x', type: 'message', role: 'assistant', model: 'claude-haiku-4-5',
          content: [{ type: 'text', text: payload.to_json }], stop_reason: 'end_turn',
          usage: { input_tokens: 100, output_tokens: 50 }
        }.to_json)
    end
  end
end
