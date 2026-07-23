require 'test_helper'

class WorkoutsHelperTest < ActionView::TestCase
  include SegmentsHelper
  include MeasurableHelper
  include MetricsHelper

  def cfj_181202_workout
    Workout.new(name: 'CFJ-181202', score_type: :time).tap do |workout|
      build_run_segment(workout, position: 1)
      build_cfj_181202_couplet(workout)
      build_run_segment(workout, position: 3)
    end
  end

  def build_run_segment(workout, position:)
    segment = workout.segments.build(position: position)
    segment.exercises.build(movement: movements(:run), position: 1, reps: 1, distance: 800, distance_unit: :meter)
  end

  def build_cfj_181202_couplet(workout)
    segment = workout.segments.build(rounds: 10, position: 2)
    segment.exercises.build(movement: movements(:handstand_push_up), position: 1, reps: 10)
    segment.exercises.build(movement: movements(:single_leg_squat), position: 2, reps: 10)
  end

  test 'renders one round for time workouts as for time' do
    workout = Workout.new(name: 'Murph', score_type: :time)
    workout.segments.build(position: 1)

    assert_equal 'For Time', workout_objective(workout)
  end

  test 'renders a segment-less workout with a generic fallback objective' do
    workout = Workout.new(name: 'Empty Workout', score_type: :time)

    assert_equal 'For time', workout_objective(workout)
  end

  test 'renders set-based lifting workouts as sets for load' do
    workout = Workout.new(name: 'Back Squat 5x5', score_type: :weight)
    segment = workout.segments.build(rounds: 5, position: 1)
    segment.exercises.build(movement: movements(:back_squat), position: 1, reps: 5, load: 0)

    assert_equal '5 sets for load', workout_objective(workout)
  end

  test 'renders variable set-based lifting workouts as sets for load' do
    workout = Workout.new(name: 'Power Clean Heavy Day', score_type: :weight)
    segment = workout.segments.build(position: 1)
    movement = Movement.find_or_create_by!(name: 'Power Clean')
    [3, 3, 2, 2, 1, 1, 1, 1].each.with_index do |reps, index|
      segment.exercises.build(movement: movement, position: index + 1, reps: reps)
    end

    assert_equal '8 sets for load', workout_objective(workout)
  end

  test 'renders weight-scored rounds as sets for load without a prescribed load' do
    workout = Workout.create!(name: 'Back Squat 5x5', score_type: :weight)
    segment = workout.segments.create!(rounds: 5, position: 1)
    segment.exercises.create!(movement: movements(:back_squat), position: 1, reps: 5, load: 0)

    workout.exercises.each { |exercise| exercise.update!(load: nil, load_unit: nil, female_load: nil, male_load: nil) }

    assert_equal '5 sets for load', workout_objective(workout.reload)
  end

  test 'renders timed max-finding workouts as max load clocks' do
    workout = Workout.new(name: 'Back Squat Max', score_type: :weight)
    segment = workout.segments.build(position: 1)
    segment.exercises.build(movement: movements(:back_squat), position: 1, reps: 4,
                            duration_seconds: 240, load_unit: :lb)
    workout.valid? # canonicalizes load_unit into the load: 0 find-a-max sentinel

    assert_equal 'For load', workout_objective(workout)
  end

  test 'renders fixed-rep amraps as rounds and reps' do
    workout = Workout.new(name: 'AMRAP Couplet', score_type: :rep)
    segment = workout.segments.build(time_seconds: 600, position: 1)
    segment.exercises.build(movement: movements(:pullup), position: 1, reps: 10)
    segment.exercises.build(movement: movements(:pushup), position: 2, reps: 15)

    assert_equal 'As many rounds and reps as possible in 10 minutes', workout_objective(workout)
  end

  test 'renders segmented rep-scored clocks as total reps' do
    workout = Workout.new(name: 'Segmented Total Reps', score_type: :rep)

    first = workout.segments.build(time_seconds: 600, position: 1)
    first.exercises.build(movement: movements(:run), position: 1, reps: 1, distance: 200, distance_unit: :meter)

    second = workout.segments.build(time_seconds: 600, position: 2)
    second.exercises.build(movement: movements(:pushup), position: 1, reps: 0)

    assert_equal 'On a 20-minute clock for total reps', workout_objective(workout)
  end

  test 'renders segmented rep-scored clocks from segment windows' do
    workout = Workout.new(name: 'Windowed Reps', score_type: :rep)

    first = workout.segments.build(time_seconds: 300, position: 1)
    first.exercises.build(movement: movements(:run), position: 1, reps: 1, distance: 200, distance_unit: :meter)
    first.exercises.build(movement: movements(:pushup), position: 2, reps: 0)

    second = workout.segments.build(time_seconds: 300, position: 2)
    second.exercises.build(movement: movements(:run), position: 1, reps: 1, distance: 200, distance_unit: :meter)
    second.exercises.build(movement: movements(:pullup), position: 2, reps: 0)

    assert_equal 'On a 10-minute clock for total reps', workout_objective(workout)
  end

  test 'renders a sequential workout with one inner rounds segment as for time' do
    assert_equal 'For Time', workout_objective(cfj_181202_workout)
  end

  test 'renders timed rep-scored rounds as round amraps' do
    workout = Workout.new(name: 'Back Squat 5x5', score_type: :rep)
    segment = workout.segments.build(rounds: 5, time_seconds: 180, position: 1)
    segment.exercises.build(movement: movements(:back_squat), position: 1, reps: 5, load: 0)

    assert_equal '5 rounds, complete as many reps as possible in 3 minutes of', workout_objective(workout)
  end

  test 'renders time-capped ascending ladders' do
    workout = Workout.new(score_type: :rep, ladder_step: 3)
    workout.segments.build(time_seconds: 420, position: 1)

    assert_equal 'As many reps as possible in 7 minutes, ascending ladder, +3 reps each round',
                 workout_objective(workout)
  end

  test 'renders cap-less ascending ladders' do
    workout = Workout.new(score_type: :rep, ladder_step: 2)

    assert_equal 'Ascending ladder, +2 reps each round', workout_objective(workout)
  end

  test 'has no team descriptor for an individual workout' do
    assert_nil team_objective(Workout.new(score_type: :time))
  end

  test 'renders a two-athlete workout as partner' do
    assert_equal 'Partner', team_objective(Workout.new(score_type: :time, team_size: 2))
  end

  test 'renders a larger team workout as team of n' do
    assert_equal 'Team of 4', team_objective(Workout.new(score_type: :time, team_size: 4))
  end

  test 'renders a workout as paste-text-box text' do
    workout = Workout.new(name: 'Fran', score_type: :time)
    segment = workout.segments.build(interval_scheme: '21-15-9', position: 1)
    segment.exercises.build(movement: movements(:thruster), position: 1, reps: 1, load: 95)
    segment.exercises.build(movement: movements(:pullup), position: 2, reps: 1)

    assert_equal "Fran\n21-15-9 for time\nThruster (95 lbs)\nPull Up", workout_as_text(workout)
  end

  test 'renders sequential workout text without lifting an inner rounds segment to the objective' do
    assert_equal "CFJ-181202\nFor Time\n800 meter Run\nThen, 10 rounds of\n10 Handstand Push-ups\n" \
                 "10 Single-leg Squats\n800 meter Run",
                 workout_as_text(cfj_181202_workout)
  end

  test 'includes time cap and notes in the paste-text-box text' do
    workout = Workout.create!(name: 'Capped Workout', score_type: :time, time_cap_seconds: 1200,
                              notes: 'Scale as needed.')
    workout.segments.create!(position: 1).exercises.create!(movement: movements(:run), position: 1, reps: 1,
                                                            distance: 400, distance_unit: :meter)

    assert_equal "Capped Workout\nFor Time\n400 meter Run\nTime cap: 20:00\nScale as needed.",
                 workout_as_text(workout.reload)
  end
end
