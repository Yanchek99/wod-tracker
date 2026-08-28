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

  test 'renders a repeated-group max-rep block as AMRAP with a clock time, dropping the block name' do
    workout = Workout.new(name: 'CF-260825', score_type: :rep)
    2.times do |round|
      %i[pullup pushup].each_with_index do |movement, block|
        segment = workout.segments.build(name: "Block #{block + 1}: Run + Max", time_seconds: 180,
                                         position: (round * 2) + block + 1)
        segment.exercises.build(movement: movements(:run), position: 1, reps: 1, distance: 400, distance_unit: :meter)
        segment.exercises.build(movement: movements(movement), position: 2, reps: 0)
      end
    end

    assert_equal 'AMRAP in 3:00', segment_objective(workout.segments.first, then_prefix: true)
  end

  test 'keeps the named max-rep phrasing for a max-rep block that is not part of a repeated group' do
    workout = Workout.new(name: 'Windowed', score_type: :rep)
    first = workout.segments.build(name: '0:00-5:00', time_seconds: 300, position: 1)
    first.exercises.build(movement: movements(:pushup), position: 1, reps: 0)
    second = workout.segments.build(name: '5:00-10:00', time_seconds: 300, position: 2)
    second.exercises.build(movement: movements(:pullup), position: 1, reps: 0)

    assert_equal '0:00-5:00: max reps in 5 minutes', segment_objective(workout.segments.first)
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

  test 'keeps objectives for new explicit unnamed unschemed segments' do
    workout = Workout.new(name: 'Plain', score_type: :time)
    segment = workout.segments.build(position: 1)

    assert segment_objective?(segment)
  end

  test 'suppresses objectives for scheme-backed implicit workout-part segment wrappers' do
    workout = Workout.create!(name: 'Back Squat 5x5', score_type: :weight)
    segment = workout.segments.create!(position: 1, rounds: 5)

    assert_not segment_objective?(segment)
  end

  test 'suppresses objectives for unschemed implicit workout-part segment wrappers' do
    workout = Workout.create!(name: 'Plain Chipper', score_type: :time)
    segment = workout.segments.create!(position: 1)

    assert_not segment_objective?(segment)
  end

  test 'an unschemed, unnamed segment has no objective text' do
    segment = Segment.new
    assert_nil segment_objective(segment)
  end

  test 'renders a segments trailing rest with a whole-minute duration in minutes' do
    assert_equal 'Rest 1 minute', segment_rest(Segment.new(rest_seconds: 60))
  end

  test 'renders a segments trailing rest with a partial-minute duration in seconds' do
    assert_equal 'Rest 90 seconds', segment_rest(Segment.new(rest_seconds: 90))
  end

  test 'has no rest line when the segment carries no rest of its own' do
    assert_nil segment_rest(Segment.new)
  end
end
