require 'test_helper'

class WorkoutTest < ActiveSupport::TestCase
  test 'orders segments by position' do
    workout = Workout.create!(name: 'Segmented', score_type: :time)
    second = workout.segments.create!(position: 2)
    first = workout.segments.create!(position: 1)

    assert_equal [first, second], workout.segments.to_a
  end

  test 'assigns an unpositioned segment after the existing ones' do
    workout = Workout.create!(name: 'Segmented', score_type: :time)
    workout.segments.create!(position: 1)
    unpositioned = workout.segments.build

    unpositioned.valid?

    assert_equal 2, unpositioned.position
  end

  test 'a flat, unschemed sole segment is for time' do
    workout = Workout.create!(name: 'Murph', score_type: :time)
    segment = workout.segments.create!(position: 1)
    segment.exercises.create!(movement: movements(:run), position: 1, reps: 1, distance: 1600, distance_unit: :meter)

    assert_predicate workout, :rounds_for_time?
    assert_not_predicate workout, :amrap?
  end

  test 'a sole segment with an interval scheme is not rounds-for-time' do
    workout = Workout.create!(name: 'Fran', score_type: :time)
    workout.segments.create!(interval_scheme: '21-15-9', position: 1)

    assert_not_predicate workout, :rounds_for_time?
    assert_predicate workout, :interval?
  end

  test 'a lone schemed segment among unschemed named ones governs the workout (Brenton)' do
    workout = Workout.create!(name: 'Brenton', score_type: :time)
    main = workout.segments.create!(rounds: 5, position: 1)
    main.exercises.create!(movement: movements(:run), position: 1, reps: 1, distance: 30, distance_unit: :meter)
    penalty = workout.segments.create!(position: 2, name: 'After every 5 reps')
    penalty.exercises.create!(movement: movements(:pullup), position: 1, reps: 3)

    assert_equal main, workout.governing_segment
    assert_predicate workout, :rounds_for_time?
  end

  test 'multiple schemed segments have no governing segment (Alec)' do
    workout = Workout.create!(name: 'Alec', score_type: :time)
    triplet = workout.segments.create!(rounds: 3, position: 1)
    triplet.exercises.create!(movement: movements(:pushup), position: 1, reps: 9)
    middle = workout.segments.create!(position: 2)
    middle.exercises.create!(movement: movements(:run), position: 1, reps: 1, distance: 1000, distance_unit: :meter)
    finisher = workout.segments.create!(rounds: 5, position: 3)
    finisher.exercises.create!(movement: movements(:pullup), position: 1, reps: 10)

    assert_nil workout.governing_segment
    assert_predicate workout, :rounds_for_time?
  end

  test 'a rep-scored AMRAP split across timed blocks is segmented_total_reps even with no governing segment' do
    workout = Workout.create!(name: 'Segmented Total Reps', score_type: :rep)
    first = workout.segments.create!(name: '0:00-5:00', time_seconds: 300, position: 1)
    first.exercises.create!(movement: movements(:row), position: 1, reps: 1, distance: 250, distance_unit: :meter)
    second = workout.segments.create!(name: '5:00-10:00', time_seconds: 300, position: 2)
    second.exercises.create!(movement: movements(:run), position: 1, reps: 1, distance: 400, distance_unit: :meter)

    assert_nil workout.governing_segment
    assert_predicate workout, :segmented_total_reps?
  end

  test 'computes reps per round from rep exercises' do
    assert_equal 25, workouts(:amrap_couplet).amrap_reps_per_round
  end

  test 'computes reps per round from explicit distance, reps, and calories' do
    assert_equal 60, workouts(:amrap_mixed).amrap_reps_per_round
  end

  test 'does not compute reps per round for unconfigured distance' do
    assert_nil workouts(:amrap_unknown_distance).amrap_reps_per_round
  end

  test 'identifies segmented total-rep clocks' do
    assert_predicate workouts(:segmented_total_reps), :segmented_total_reps?
  end

  test 'identifies segmented total-rep clocks from segment windows' do
    workout = Workout.new(name: 'Windowed Reps', score_type: :rep)

    first = workout.segments.build(time_seconds: 300, position: 1)
    first.exercises.build(movement: movements(:run), position: 1, reps: 1, distance: 200, distance_unit: :meter)
    first.exercises.build(movement: movements(:pushup), position: 2, reps: 0)

    second = workout.segments.build(time_seconds: 300, position: 2)
    second.exercises.build(movement: movements(:run), position: 1, reps: 1, distance: 200, distance_unit: :meter)
    second.exercises.build(movement: movements(:pullup), position: 2, reps: 0)

    assert_predicate workout, :segmented_total_reps?
  end

  test 'does not identify empty segmented clocks as total-rep clocks' do
    workout = Workout.new(name: 'Empty Segments', score_type: :rep)
    workout.segments.build(time_seconds: 300, position: 1)

    assert_not_predicate workout, :segmented_total_reps?
  end

  test 'distance scoring takes precedence over legacy rep marker' do
    component = exercises(:amrap_mixed_row).score_component

    assert_equal 'meter', component[:measurement]
    assert_equal 30, component[:score_reps]
  end

  test 'identifies set-based lifting workouts' do
    assert workouts(:back_squat_5x5).set_based_lifting?
    assert_not workouts(:amrap_couplet).set_based_lifting?
  end

  test 'identifies timed max-finding workouts' do
    workout = Workout.new(name: 'Back Squat Max', score_type: :weight)
    segment = workout.segments.build(position: 1)
    segment.exercises.build(movement: movements(:back_squat), position: 1, reps: 4,
                            duration_seconds: 240, load_unit: :lb)
    workout.save! # canonicalizes load_unit into the load: 0 find-a-max sentinel

    assert_predicate workout, :max_finding?
    assert_predicate workout, :calculated_lifting_score?
  end

  test 'identifies multi-exercise max-finding workouts without auto-combining scores' do
    workout = Workout.new(name: 'Dragon', score_type: :weight)
    segment = workout.segments.build(position: 1)
    segment.exercises.build(movement: movements(:back_squat), position: 1, reps: 4,
                            duration_seconds: 240, load_unit: :lb)
    segment.exercises.build(movement: movements(:thruster), position: 2, reps: 4,
                            duration_seconds: 240, load_unit: :lb)
    workout.save! # canonicalizes load_unit into the load: 0 find-a-max sentinel

    assert_predicate workout, :max_finding?
    assert_not_predicate workout, :calculated_lifting_score?
  end

  test 'does not identify rep-scored rounds with load-bearing exercises as set-based lifting' do
    workout = workouts(:back_squat_5x5)
    workout.update!(score_type: :rep)

    assert_not workout.set_based_lifting?
  end

  test 'identifies weight-scored rounds as set-based lifting without a prescribed load' do
    workout = workouts(:back_squat_5x5)
    workout.exercises.each { |exercise| exercise.update!(load: nil, load_unit: nil, female_load: nil, male_load: nil) }

    assert workout.reload.set_based_lifting?
  end

  test 'a workout without a team size is an individual workout' do
    workout = Workout.new(name: 'Solo', score_type: :time)

    assert_not_predicate workout, :team?
    assert_not_predicate workout, :partner?
  end

  test 'identifies partner and team workouts from team size' do
    partner = Workout.new(name: 'Partner', score_type: :time, team_size: 2)
    team = Workout.new(name: 'Team', score_type: :time, team_size: 4)

    assert_predicate partner, :team?
    assert_predicate partner, :partner?
    assert_predicate team, :team?
    assert_not_predicate team, :partner?
  end

  test 'rejects a team size below two' do
    workout = Workout.new(name: 'Bad Team', score_type: :time, team_size: 1)

    assert_not_predicate workout, :valid?
    assert_includes workout.errors.attribute_names, :team_size
  end

  test 'allows a nil team size' do
    workout = Workout.new(name: 'Solo', score_type: :time, team_size: nil)
    segment = workout.segments.build(position: 1)
    segment.exercises.build(movement: movements(:run), position: 1, reps: 1)

    assert_predicate workout, :valid?
  end

  test 'replace_with_extraction! replaces attributes and segments in memory without persisting' do
    workout = Workout.create!(name: 'Old Name', score_type: :time)
    segment = workout.segments.create!(position: 1)
    segment.exercises.create!(movement: movements(:pullup), position: 1, reps: 10)

    # Loaded the same way WorkoutsController#set_workout loads @workout, so the segments
    # association is already eager-loaded before replace_with_extraction! touches it.
    workout = Workout.includes(segments: :exercises).find(workout.id)
    old_segment = workout.segments.sole

    extracted = Workout.new(name: 'New Name', score_type: :rep, notes: 'extracted notes')
    new_segment = extracted.segments.build(position: 1)
    new_segment.exercises.build(movement: movements(:run), position: 1, reps: 5)

    workout.replace_with_extraction!(extracted)

    assert_equal 'New Name', workout.name
    assert_equal 'rep', workout.score_type
    assert_equal 'extracted notes', workout.notes.to_plain_text.strip

    assert_predicate old_segment, :marked_for_destruction?

    built_segment = workout.segments.reject(&:marked_for_destruction?).sole
    assert_predicate built_segment, :new_record?
    assert_equal movements(:run), built_segment.exercises.sole.movement

    workout.reload
    assert_equal 'Old Name', workout.name
  end

  test 'replace_with_extraction! persists the replacement when saved' do
    workout = Workout.create!(name: 'Old Name', score_type: :time)
    segment = workout.segments.create!(position: 1)
    segment.exercises.create!(movement: movements(:pullup), position: 1, reps: 10)
    old_segment_id = segment.id

    workout = Workout.includes(segments: :exercises).find(workout.id)

    extracted = Workout.new(name: 'New Name', score_type: :rep)
    new_segment = extracted.segments.build(position: 1)
    new_segment.exercises.build(movement: movements(:run), position: 1, reps: 5)

    workout.replace_with_extraction!(extracted)
    assert workout.save

    workout.reload
    assert_equal 'New Name', workout.name
    assert_not Segment.exists?(old_segment_id)
    assert_equal [movements(:run)], workout.segments.sole.exercises.map(&:movement)
  end
end
