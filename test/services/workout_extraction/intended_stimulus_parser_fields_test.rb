require 'test_helper'

module WorkoutExtraction
  # The goal, heavy-day, interval, rest and effort fields the parser extracts (#1992).
  class IntendedStimulusParserFieldsTest < ActiveSupport::TestCase
    setup do
      @workout = Workout.create!(name: 'CF-Stimulus-Fields', score_type: :time,
                                 intended_stimulus_notes: 'Every set at or near 75% of your 1-rep max.')
      segment = @workout.segments.create!(rounds: 5, position: 1)
      @thruster = segment.exercises.create!(movement: movements(:thruster), position: 1, reps: 5, load: 95)
    end

    test 'extracts heavy-day hold-percent fields' do
      stub_stimulus_response(goal: 'heavy_hold_percent', percent_1rm_low: 75, percent_1rm_high: 75,
                             working_sets_low: 5, working_sets_high: 5, rest_seconds_low: 120,
                             rest_seconds_high: 180, movements: [])

      IntendedStimulusParser.call(@workout)

      assert_equal ['heavy_hold_percent', 75, 75, 5, 5, 120, 180, 'extracted'],
                   @workout.reload.values_at(:stimulus_goal, :stimulus_percent_1rm_low, :stimulus_percent_1rm_high,
                                             :stimulus_working_sets_low, :stimulus_working_sets_high,
                                             :stimulus_rest_seconds_low, :stimulus_rest_seconds_high,
                                             :stimulus_source)
    end

    test 'extracts interval and round-time fields' do
      stub_stimulus_response(goal: 'intervals', interval_work_seconds: 270, interval_rest_seconds_min: 90,
                             round_seconds_low: 120, round_seconds_high: 180, movements: [])

      IntendedStimulusParser.call(@workout)

      assert_equal ['intervals', 270, 90, 120, 180],
                   @workout.reload.values_at(:stimulus_goal, :stimulus_interval_work_seconds,
                                             :stimulus_interval_rest_seconds_min, :stimulus_round_seconds_low,
                                             :stimulus_round_seconds_high)
    end

    test 'extracts per-movement rest and effort' do
      stub_stimulus_response(movements: [{ movement_name: 'Thruster', rest_max_seconds: 10, effort: 'sprint' }])

      IntendedStimulusParser.call(@workout)

      assert_equal [10, 'sprint', 'extracted'],
                   @thruster.reload.values_at(:stimulus_rest_max_seconds, :stimulus_effort, :stimulus_source)
    end

    test 'drops an unknown goal or effort' do
      stub_stimulus_response(goal: 'metcon', movements: [{ movement_name: 'Thruster', effort: 'easy' }])

      IntendedStimulusParser.call(@workout)

      assert_nil @workout.reload.stimulus_goal
      assert_nil @thruster.reload.stimulus_effort
    end

    test 'stamps the workout extracted even when nothing usable comes back' do
      stub_stimulus_response(movements: [])

      IntendedStimulusParser.call(@workout)

      assert_equal 'extracted', @workout.reload.stimulus_source
    end

    test 'never extracts onto an authored workout, even when forced' do
      @workout.update!(stimulus_source: :authored, stimulus_range_high: 600)
      stub_stimulus_response(range_high: 300, movements: [])

      IntendedStimulusParser.call(@workout, force: true)

      assert_equal [600, 'authored'], @workout.reload.values_at(:stimulus_range_high, :stimulus_source)
      assert_not_requested :post, 'https://api.anthropic.com/v1/messages'
    end

    test 'skips an already-extracted workout unless forced' do
      @workout.update!(stimulus_source: :extracted)
      stub_stimulus_response(goal: 'for_time', movements: [])

      IntendedStimulusParser.call(@workout)

      assert_nil @workout.reload.stimulus_goal

      IntendedStimulusParser.call(@workout, force: true)

      assert_equal 'for_time', @workout.reload.stimulus_goal
    end

    test 'a weight-scored range must be a percent of 1RM' do
      @workout.update!(score_type: :weight)
      stub_stimulus_response(range_low: 85, range_high: 300, movements: [])

      IntendedStimulusParser.call(@workout)

      # 300 is not a percent and is dropped; the lone remaining bound is a ceiling, as for any range.
      assert_equal [nil, 85], @workout.reload.values_at(:stimulus_range_low, :stimulus_range_high)
    end

    test 'a JSON response that is not an object raises ExtractionError' do
      stub_request(:post, 'https://api.anthropic.com/v1/messages')
        .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: {
          id: 'msg_x', type: 'message', role: 'assistant', model: 'claude-haiku-4-5',
          content: [{ type: 'text', text: '[1, 2]' }], stop_reason: 'end_turn',
          usage: { input_tokens: 1, output_tokens: 1 }
        }.to_json)

      assert_raises(IntendedStimulusParser::ExtractionError) { IntendedStimulusParser.call(@workout) }
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
