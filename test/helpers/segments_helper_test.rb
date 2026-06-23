require 'test_helper'

class SegmentsHelperTest < ActionView::TestCase
  test 'renders rounds-only segments as rounds of' do
    assert_equal '10 rounds of', segment_objective(Segment.new(rounds: 10))
  end

  test 'prefixes subsequent segments with then' do
    assert_equal 'Then, 10 rounds of', segment_objective(Segment.new(rounds: 10), then_prefix: true)
  end

  test 'renders amrap segments with whole-minute durations in minutes' do
    assert_equal 'As many rounds as possible in 10 minutes', segment_objective(Segment.new(time_seconds: 600))
  end

  test 'renders amrap segments with partial-minute durations in seconds' do
    assert_equal 'As many rounds as possible in 90 seconds', segment_objective(Segment.new(time_seconds: 90))
  end

  test 'renders named max-rep segments with their time window' do
    segment = Segment.new(name: '0:00-5:00', time_seconds: 300)
    segment.exercises.build(reps: 0)

    assert_equal '0:00-5:00: max reps in 5 minutes', segment_objective(segment, then_prefix: true)
  end

  test 'renders emom segments with their duration in minutes' do
    assert_equal 'EMOM 10', segment_objective(Segment.new(time_seconds: 600, rounds: 10))
  end

  test 'renders timed rounds segments with their duration in minutes' do
    assert_equal '4 25-minute rounds', segment_objective(Segment.new(time_seconds: 1500, rounds: 4))
  end

  test 'renders interval segments as their scheme' do
    assert_equal '21-15-9 of', segment_objective(Segment.new(interval_scheme: '21-15-9'))
  end

  test 'falls back to the segment name' do
    assert_equal 'Skill work:', segment_objective(Segment.new(name: 'Skill work'))
  end

  test 'prefixes subsequent named segments with then' do
    assert_equal 'Then, Middle:', segment_objective(Segment.new(name: 'Middle'), then_prefix: true)
  end

  test 'falls back to a generic label for empty segments' do
    assert_equal 'Segment:', segment_objective(Segment.new)
  end
end
