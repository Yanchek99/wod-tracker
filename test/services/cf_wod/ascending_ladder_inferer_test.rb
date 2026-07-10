require 'test_helper'

module CfWod
  class AscendingLadderInfererTest < ActiveSupport::TestCase
    test 'infers the first rung and step from an Etc.-terminated 3/6/9 couplet' do
      first_rung = [exercise_line('pull-ups', 3), exercise_line('push-ups', 3)]
      parsed_lines = first_rung + [
        exercise_line('pull-ups', 6), exercise_line('push-ups', 6),
        exercise_line('pull-ups', 9), exercise_line('push-ups', 9), etc_line
      ]

      assert_equal({ ladder_step: 3, lines: first_rung }, AscendingLadderInferer.call(parsed_lines))
    end

    test 'raises when Etc. follows fewer than two complete rungs' do
      parsed_lines = [exercise_line('pull-ups', 3), exercise_line('push-ups', 3), etc_line]

      assert_ambiguous(parsed_lines)
    end

    test 'raises when movement order changes between rungs' do
      parsed_lines = [
        exercise_line('pull-ups', 3), exercise_line('push-ups', 3),
        exercise_line('push-ups', 6), exercise_line('pull-ups', 6), etc_line
      ]

      assert_ambiguous(parsed_lines)
    end

    test 'raises when rep steps are inconsistent' do
      parsed_lines = [
        exercise_line('pull-ups', 3), exercise_line('push-ups', 3),
        exercise_line('pull-ups', 6), exercise_line('push-ups', 6),
        exercise_line('pull-ups', 10), exercise_line('push-ups', 10), etc_line
      ]

      assert_ambiguous(parsed_lines)
    end

    test 'raises when reps do not increase' do
      parsed_lines = [
        exercise_line('pull-ups', 3), exercise_line('push-ups', 3),
        exercise_line('pull-ups', 3), exercise_line('push-ups', 3), etc_line
      ]

      assert_ambiguous(parsed_lines)
    end

    test 'raises when Etc. has surrounding whitespace' do
      parsed_lines = [
        exercise_line('pull-ups', 3), exercise_line('push-ups', 3),
        exercise_line('pull-ups', 6), exercise_line('push-ups', 6),
        { attrs: {}, raw_line: ' Etc. ' }
      ]

      assert_ambiguous(parsed_lines)
    end

    test 'raises when reps are malformed' do
      parsed_lines = [
        exercise_line('pull-ups', '3 reps'), exercise_line('push-ups', 3),
        exercise_line('pull-ups', 6), exercise_line('push-ups', 6), etc_line
      ]

      assert_ambiguous(parsed_lines)
    end

    private

    def exercise_line(movement_name, reps)
      { attrs: { movement_name: movement_name, reps: reps }, raw_line: "#{reps} #{movement_name}" }
    end

    def etc_line
      { attrs: {}, raw_line: 'Etc.' }
    end

    def assert_ambiguous(parsed_lines)
      error = assert_raises(WorkoutParser::UnparseableError) { AscendingLadderInferer.call(parsed_lines) }
      assert_equal 'ambiguous ascending ladder ending in Etc.', error.message
    end
  end
end
