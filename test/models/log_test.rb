require 'test_helper'

class LogTest < ActiveSupport::TestCase
  test 'builds one movement recording per set for set-based lifting workouts' do
    log = workouts(:back_squat_5x5).logs.build(user: users(:mathew), score_type: :weight)
    log.build_movement_logs

    assert_equal 5, log.movement_logs.size

    log.movement_logs.each do |movement_log|
      assert_equal movements(:back_squat), movement_log.movement
      assert_equal 5, movement_log.reps
      assert_nil movement_log.load
      assert_not movement_log.records_load?
    end
  end

  test 'auto-populates set_breakdown as one set for a single-exercise weightlifting day' do
    log = workouts(:back_squat_5x5).logs.build(user: users(:mathew), score_type: :weight)
    log.build_movement_logs

    log.movement_logs.each do |movement_log|
      assert_equal [5], movement_log.set_breakdown
    end
  end

  test 'does not auto-populate set_breakdown for a single-exercise interval-scheme workout' do
    workout = Workout.new(name: 'Interval Ladder Test', score_type: :time)
    segment = workout.segments.build(position: 1, interval_scheme: '10-5')
    segment.exercises.build(movement: movements(:back_squat), position: 1, reps: 1)
    workout.save!

    log = workout.logs.build(user: users(:mathew), score_type: :time)
    log.build_movement_logs

    movement_log = log.movement_logs.first
    assert_equal 15, movement_log.reps
    assert_empty movement_log.set_breakdown
  end

  test 'does not auto-populate set_breakdown for a multi-exercise weightlifting workout' do
    workout = Workout.new(name: 'Multi Weightlifting Test', score_type: :time)
    segment = workout.segments.build(position: 1)
    segment.exercises.build(movement: movements(:back_squat), position: 1, reps: 5)
    segment.exercises.build(movement: movements(:thruster), position: 2, reps: 5)
    workout.save!

    log = workout.logs.build(user: users(:mathew), score_type: :time)
    log.build_movement_logs

    log.movement_logs.each do |movement_log|
      assert_empty movement_log.set_breakdown
    end
  end

  test 'does not auto-populate set_breakdown for a single-exercise non-weightlifting workout' do
    workout = Workout.new(name: 'Single Gymnastics Test', score_type: :time)
    segment = workout.segments.build(position: 1)
    segment.exercises.build(movement: movements(:pullup), position: 1, reps: 10)
    workout.save!

    log = workout.logs.build(user: users(:mathew), score_type: :time)
    log.build_movement_logs

    movement_log = log.movement_logs.first
    assert_equal 10, movement_log.reps
    assert_empty movement_log.set_breakdown
  end

  test 'auto-populates set_breakdown for a single logged rep regardless of family or shape' do
    workout = Workout.new(name: 'Single Rep Test', score_type: :time)
    segment = workout.segments.build(position: 1)
    segment.exercises.build(movement: movements(:pullup), position: 1, reps: 1)
    workout.save!

    log = workout.logs.build(user: users(:mathew), score_type: :time)
    log.build_movement_logs

    movement_log = log.movement_logs.first
    assert_equal 1, movement_log.reps
    assert_equal [1], movement_log.set_breakdown
  end

  test 'does not auto-populate set_breakdown for the unspecified max-reps sentinel' do
    workout = Workout.new(name: 'Max Reps Test', score_type: :time)
    segment = workout.segments.build(position: 1)
    segment.exercises.build(movement: movements(:pullup), position: 1, reps: 0)
    workout.save!

    log = workout.logs.build(user: users(:mathew), score_type: :time)
    log.build_movement_logs

    movement_log = log.movement_logs.first
    assert_equal 0, movement_log.reps
    assert_empty movement_log.set_breakdown
  end

  test 'does not auto-populate set_breakdown for a reps == 1 AMRAP-repeated movement' do
    workout = Workout.new(name: 'Reps One AMRAP Test', score_type: :rep)
    segment = workout.segments.build(time_seconds: 600, position: 1)
    segment.exercises.build(movement: movements(:rope_climb), position: 1, reps: 1)
    segment.exercises.build(movement: movements(:pushup), position: 2, reps: 10)
    workout.save!

    log = workout.logs.build(user: users(:mathew), score_type: :rep, score_value: '110')
    log.build_movement_logs

    rope_log = log.movement_logs.find { |ml| ml.movement == movements(:rope_climb) }
    assert_equal 1, rope_log.reps
    assert_empty rope_log.set_breakdown

    assert log.valid?, log.errors.full_messages.to_sentence

    rope_log.set_breakdown_text = '1,1,1,1,1,1,1,1,1,1'
    assert log.valid?, log.errors.full_messages.to_sentence
    assert_equal 10, rope_log.set_breakdown_target_reps
  end

  test 'does not auto-populate set_breakdown for a reps == 1 ascending-ladder movement' do
    workout = Workout.new(name: 'Reps One Ladder Test', score_type: :rep, ladder_step: 1)
    segment = workout.segments.build(time_seconds: 600, position: 1)
    segment.exercises.build(movement: movements(:rope_climb), position: 1, reps: 1)
    workout.save!

    log = workout.logs.build(user: users(:mathew), score_type: :rep, score_value: '5')
    log.build_movement_logs

    rope_log = log.movement_logs.first
    assert_equal 1, rope_log.reps
    assert_empty rope_log.set_breakdown
    assert log.valid?, log.errors.full_messages.to_sentence
  end

  test 'does not silently overwrite a genuine self-reported breakdown that mismatches reps' do
    log = workouts(:back_squat_5x5).logs.build(user: users(:mathew), score_type: :weight)
    log.build_movement_logs

    movement_log = log.movement_logs.first
    assert_equal [5], movement_log.set_breakdown

    movement_log.set_breakdown_text = '4'

    assert_not log.valid?
    assert_equal [4], movement_log.set_breakdown
    assert_includes movement_log.errors[:set_breakdown], 'must sum to reps'
  end

  test 'parses duration score values before score type assignment' do
    log = Log.new(workout: workouts(:fran), user: users(:mathew), score_value: '5:30', score_type: :time)

    assert_equal 330, log.score_value
  end

  test 'builds timed round movement recordings with per-round prescribed reps' do
    workout = workouts(:back_squat_5x5)
    workout.update!(score_type: :rep)

    log = workout.logs.build(user: users(:mathew), score_type: :rep)
    log.build_movement_logs

    assert_equal 1, log.movement_logs.size
    assert_equal 5, log.movement_logs.first.reps
  end

  test 'records per-round prescribed reps for segment exercises' do
    exercises(:segmented_hspu).update!(reps: 10)

    log = workouts(:segmented).logs.build(user: users(:mathew), score_type: :time)
    log.build_movement_logs

    hspu_log = log.movement_logs.find { |movement_log| movement_log.movement == movements(:hspu) }

    assert_equal 10, hspu_log.reps
  end

  test 'builds movement logs from direct column prescriptions' do
    workout = Workout.new(name: 'Direct Column Prescription', score_type: :time)
    segment = workout.segments.build(position: 1)
    segment.exercises.build(movement: movements(:back_squat), position: 1,
                            reps: 21, female_load: 65, male_load: 95, load_unit: :lb)
    workout.save!

    log = workout.logs.build(user: users(:mathew), score_type: :time, score_value: 180)
    log.build_movement_logs

    movement_log = log.movement_logs.first

    assert_equal 21, movement_log.reps
    assert_equal 95, movement_log.load
    assert_predicate movement_log, :records_load?
  end

  test 'calculates set-based lifting score from heaviest successful set' do
    log = workouts(:back_squat_5x5).logs.build(user: users(:mathew), score_type: :weight)
    log.build_movement_logs

    [95, 115, 135, 145, 155].each.with_index do |load, index|
      log.movement_logs[index].load = load
    end
    log.movement_logs[4].reps = 2

    assert log.valid?
    assert_equal 'lb', log.score_type
    assert_equal 145, log.score_value
  end

  test 'builds and scores one movement recording per variable lifting set' do
    workout = Workout.create!(name: 'Power Clean Heavy Day', score_type: :weight)
    segment = workout.segments.create!(position: 1)
    movement = Movement.find_or_create_by!(name: 'Power Clean')
    [3, 3, 2, 2, 1, 1, 1, 1].each.with_index do |reps, index|
      segment.exercises.create!(movement: movement, position: index + 1, reps: reps)
    end

    log = workout.logs.build(user: users(:mathew), score_type: :weight)
    log.build_movement_logs

    assert_equal [3, 3, 2, 2, 1, 1, 1, 1], log.movement_logs.map(&:reps)

    [135, 155, 175, 185, 195, 205, 215, 225].each.with_index do |load, index|
      log.movement_logs[index].load = load
    end
    log.movement_logs.last.assign_attributes(reps: 0, set_breakdown: [])

    assert log.valid?
    assert_equal 'lb', log.score_type
    assert_equal 215, log.score_value
  end

  test 'calculates single max-finding score from a successful logged load' do
    workout = Workout.create!(name: 'Back Squat Max', score_type: :weight)
    segment = workout.segments.create!(position: 1)
    segment.exercises.create!(movement: movements(:back_squat), position: 1, reps: 4,
                              duration_seconds: 240, load_unit: :lb)
    log = workout.logs.build(user: users(:mathew), score_type: :weight)
    log.build_movement_logs

    assert_equal 1, log.movement_logs.size
    assert_equal 4, log.movement_logs.first.reps
    assert_nil log.movement_logs.first.duration_seconds

    log.movement_logs.first.load = 405

    assert log.valid?
    assert_equal 'lb', log.score_type
    assert_equal 405, log.score_value
  end

  test 'does not calculate single max-finding score without completed prescribed reps' do
    workout = Workout.create!(name: 'Back Squat Max', score_type: :weight)
    segment = workout.segments.create!(position: 1)
    segment.exercises.create!(movement: movements(:back_squat), position: 1, reps: 4,
                              duration_seconds: 240, load_unit: :lb)
    log = workout.logs.build(user: users(:mathew), score_type: :weight)
    log.build_movement_logs
    log.movement_logs.first.assign_attributes(reps: 3, load: 405)

    assert log.valid?
    assert_nil log.score_value
  end

  test 'fills every blank load-bearing movement_log from score_value on a manually-scored lift' do
    exercises(:fran_thruster).update!(load: 0) # simulate the Open 21.4-style sentinel
    log = workouts(:fran).logs.build(user: users(:mathew), score_type: :weight, score_value: 225)
    log.build_movement_logs
    log.movement_logs.each { |ml| ml.load = nil }

    log.save!

    thruster_log = log.movement_logs.find { |ml| ml.movement_id == movements(:thruster).id }
    assert_equal 225, thruster_log.load
  end

  test 'does not fill a non-load-bearing movement_log' do
    log = workouts(:fran).logs.build(user: users(:mathew), score_type: :weight, score_value: 225)
    log.build_movement_logs

    log.save!

    pullup_log = log.movement_logs.find { |ml| ml.movement_id == movements(:pullup).id }
    assert_nil pullup_log.load
  end

  test 'does not override a load the athlete already entered' do
    exercises(:fran_thruster).update!(load: 0)
    log = workouts(:fran).logs.build(user: users(:mathew), score_type: :weight, score_value: 225)
    log.build_movement_logs
    thruster_log = log.movement_logs.find { |ml| ml.movement_id == movements(:thruster).id }
    thruster_log.load = 205

    log.save!

    assert_equal 205, thruster_log.reload.load
  end

  test 'does not run for a calculated_lifting_score? workout' do
    workout = Workout.create!(name: 'Isolated Calculated Score Workout', score_type: :weight)
    segment = workout.segments.create!(position: 1)
    segment.exercises.create!(movement: movements(:back_squat), position: 1, reps: 4,
                              duration_seconds: 240, load_unit: :lb)
    log = workout.logs.build(user: users(:mathew), score_type: :weight, score_value: 225)
    log.build_movement_logs

    log.save!

    log.movement_logs.each { |ml| assert_nil ml.load }
  end

  test 'does not run when score_value is blank' do
    exercises(:fran_thruster).update!(load: 0)
    log = workouts(:fran).logs.build(user: users(:mathew), score_type: :weight)
    log.build_movement_logs

    log.save!

    thruster_log = log.movement_logs.find { |ml| ml.movement_id == movements(:thruster).id }
    assert_nil thruster_log.load
  end

  test 'reloads movement_logs in build order, matching exercises_for_log_recording' do
    exercises(:fran_thruster).update!(load: 0)
    log = workouts(:fran).logs.build(user: users(:mathew), score_type: :time, score_value: 330)
    log.build_movement_logs
    log.save!

    reloaded_movement_ids = log.reload.movement_logs.map(&:movement_id)

    assert_equal workouts(:fran).exercises_for_log_recording.map(&:movement_id), reloaded_movement_ids
  end

  test 'exposes recording-relevant metrics per exercise as a public method' do
    log = workouts(:fran).logs.build(user: users(:mathew), score_type: :time)

    thruster_measurements = log.metrics_for_movement_log(exercises(:fran_thruster)).map(&:measurement)
    pullup_measurements = log.metrics_for_movement_log(exercises(:fran_pullup)).map(&:measurement)

    assert_equal %w[rep lb], thruster_measurements
    assert_equal %w[rep], pullup_measurements
  end

  test 'pre-fills implement_count when the exercise prescribes multiple implements' do
    exercises(:fran_thruster).update!(implement_count: 2)
    log = workouts(:fran).logs.build(user: users(:mathew), score_type: :time)

    log.build_movement_logs

    movement_log = log.movement_logs.find { |ml| ml.movement_id == movements(:thruster).id }
    assert_equal 2, movement_log.implement_count
  end

  test 'leaves implement_count blank when the exercise does not prescribe a count' do
    log = workouts(:fran).logs.build(user: users(:mathew), score_type: :time)

    log.build_movement_logs

    movement_log = log.movement_logs.find { |ml| ml.movement_id == movements(:thruster).id }
    assert_nil movement_log.implement_count
  end

  test 'the workouts foreign key blocks deleting a workout that still has logs' do
    workout = Workout.create!(name: 'Constrained Workout', score_type: :time)
    workout.logs.create!(user: users(:mathew), score_type: :time, score_value: 200)

    assert_raises(ActiveRecord::InvalidForeignKey) do
      Workout.where(id: workout.id).delete_all
    end
  end

  test 'computes AMRAP set_breakdown target from full rounds plus a partial-round share attributed in round order' do
    log = workouts(:amrap_couplet).logs.build(user: users(:mathew), score_type: :rep, score_value: '502')
    log.build_movement_logs

    pullup_log = log.movement_logs.find { |ml| ml.movement == movements(:pullup) }
    pushup_log = log.movement_logs.find { |ml| ml.movement == movements(:pushup) }
    pullup_log.set_breakdown_text = '10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,2'
    pushup_log.set_breakdown_text = '15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15'

    assert log.valid?, log.errors.full_messages.to_sentence
  end

  test 'gives an earlier movement in round order full credit for a partial round reached later' do
    log = workouts(:amrap_couplet).logs.build(user: users(:mathew), score_type: :rep, score_value: '512')
    log.build_movement_logs

    pullup_log = log.movement_logs.find { |ml| ml.movement == movements(:pullup) }
    pushup_log = log.movement_logs.find { |ml| ml.movement == movements(:pushup) }
    pullup_log.set_breakdown_text = '10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10'
    pushup_log.set_breakdown_text = '15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,2'

    assert log.valid?, log.errors.full_messages.to_sentence
  end

  test 'rejects an AMRAP set_breakdown that does not match the computed total across all rounds' do
    log = workouts(:amrap_couplet).logs.build(user: users(:mathew), score_type: :rep, score_value: '502')
    log.build_movement_logs

    pullup_log = log.movement_logs.find { |ml| ml.movement == movements(:pullup) }
    pullup_log.set_breakdown_text = '10,10,10' # nowhere near 202

    assert_not log.valid?
    assert_includes pullup_log.errors[:set_breakdown], 'must sum to reps'
  end

  test 'does not compute an AMRAP target when a round component is distance-based' do
    log = workouts(:amrap_mixed).logs.build(user: users(:mathew), score_type: :rep, score_value: '1+35')
    log.build_movement_logs

    pushup_log = log.movement_logs.find { |ml| ml.movement == movements(:pushup) }
    assert_equal pushup_log.reps, pushup_log.set_breakdown_target_reps
  end

  test 'set_breakdown_target_reps defaults to reps for non-AMRAP workouts' do
    log = workouts(:back_squat_5x5).logs.build(user: users(:mathew), score_type: :weight)
    log.build_movement_logs

    movement_log = log.movement_logs.first
    assert_equal movement_log.reps, movement_log.set_breakdown_target_reps
  end

  test 'computes an AMRAP target across a repeating ascending-rung ladder, attributing a partial second lap in position order' do
    # Mirrors Open 14.3: an ascending deadlift ladder (10, 15, 20, 25, 30, 35 reps) paired with
    # fixed 15-rep box jumps each rung -- 12 explicit exercise positions that repeat as a whole
    # 225-rep lap if the athlete finishes the ladder before time is up (confirmed against a real
    # reported log: 300 total reps = one full 225-rep lap, plus 75 reps into a second lap). The
    # first deadlift rung (10 reps) gets full credit for its round-1 unbroken 10, plus its round-2
    # share (10, since the 75-rep partial lap comfortably covers this first position) -- a true
    # total of 20, matching a real "10 unbroken, then broken 5-5" report.
    box_jump = Movement.find_or_create_by!(name: 'Box Jump')
    workout = Workout.new(name: 'Ladder Shape Test', score_type: :rep)
    segment = workout.segments.build(time_seconds: 480, position: 1)
    [[movements(:deadlift), 10], [box_jump, 15],
     [movements(:deadlift), 15], [box_jump, 15],
     [movements(:deadlift), 20], [box_jump, 15],
     [movements(:deadlift), 25], [box_jump, 15],
     [movements(:deadlift), 30], [box_jump, 15],
     [movements(:deadlift), 35], [box_jump, 15]].each_with_index do |(movement, reps), index|
      segment.exercises.build(movement: movement, position: index + 1, reps: reps)
    end
    workout.save!

    log = workout.logs.build(user: users(:mathew), score_type: :rep, score_value: '300')
    log.build_movement_logs

    first_rung = log.movement_logs.first
    first_rung.set_breakdown_text = '10,5,5'

    assert log.valid?, log.errors.full_messages.to_sentence
    assert_equal 20, first_rung.set_breakdown_target_reps
  end

  test 'computes ascending-ladder set_breakdown targets for full rounds with no partial round' do
    workout = Workout.new(name: 'Ascending Ladder Test', score_type: :rep, ladder_step: 3)
    segment = workout.segments.build(time_seconds: 480, position: 1)
    segment.exercises.build(movement: movements(:hspu), position: 1, reps: 3)
    segment.exercises.build(movement: movements(:clean), position: 2, reps: 3, ladder_step_every: 3,
                            female_load: 125, male_load: 185, load_unit: :lb)
    workout.save!

    log = workout.logs.build(user: users(:mathew), score_type: :rep, score_value: '45')
    log.build_movement_logs

    hspu_log = log.movement_logs.find { |ml| ml.movement == movements(:hspu) }
    clean_log = log.movement_logs.find { |ml| ml.movement == movements(:clean) }
    hspu_log.set_breakdown_text = '3,6,9,12'
    clean_log.set_breakdown_text = '3,3,3,6'

    assert log.valid?, log.errors.full_messages.to_sentence
    assert_equal 30, hspu_log.set_breakdown_target_reps
    assert_equal 15, clean_log.set_breakdown_target_reps
  end

  test 'attributes a partial ascending-ladder round to the exercise earlier in position order' do
    workout = Workout.new(name: 'Ascending Ladder Partial Test', score_type: :rep, ladder_step: 3)
    segment = workout.segments.build(time_seconds: 480, position: 1)
    segment.exercises.build(movement: movements(:hspu), position: 1, reps: 3)
    segment.exercises.build(movement: movements(:clean), position: 2, reps: 3, ladder_step_every: 3,
                            female_load: 125, male_load: 185, load_unit: :lb)
    workout.save!

    log = workout.logs.build(user: users(:mathew), score_type: :rep, score_value: '50')
    log.build_movement_logs

    hspu_log = log.movement_logs.find { |ml| ml.movement == movements(:hspu) }
    clean_log = log.movement_logs.find { |ml| ml.movement == movements(:clean) }
    hspu_log.set_breakdown_text = '3,6,9,12,5'
    clean_log.set_breakdown_text = '3,3,3,6'

    assert log.valid?, log.errors.full_messages.to_sentence
    assert_equal 35, hspu_log.set_breakdown_target_reps
    assert_equal 15, clean_log.set_breakdown_target_reps
    assert_equal [[3], [6], [9], [12], [5]], hspu_log.set_breakdown_rounds
  end

  test 'reconstructs interval-scheme round sizes from a segment for display grouping' do
    log = logs(:brooke_fran)
    thruster_log = log.movement_logs.find { |ml| ml.movement == movements(:thruster) }
    thruster_log.reps = 45
    thruster_log.set_breakdown = [8, 7, 6, 8, 7, 9]

    assert_equal [[8, 7, 6], [8, 7], [9]], thruster_log.set_breakdown_rounds
  end

  test 'reconstructs AMRAP round sizes across full rounds plus a partial round for display grouping' do
    workout = workouts(:amrap_couplet)
    log = workout.logs.build(user: users(:mathew), score_type: :rep, score_value: '502')
    log.build_movement_logs

    pullup_log = log.movement_logs.find { |ml| ml.movement == movements(:pullup) }
    pullup_log.reps = 10
    pullup_log.set_breakdown = Array.new(20, 10) + [2]

    assert log.valid?, log.errors.full_messages.to_sentence
    assert_equal ([[10]] * 20) + [[2]], pullup_log.set_breakdown_rounds
  end

  test 'falls back to one ungrouped round when no round structure is knowable' do
    log = workouts(:back_squat_5x5).logs.build(user: users(:mathew), score_type: :weight)
    log.build_movement_logs

    movement_log = log.movement_logs.first
    movement_log.set_breakdown = [3, 2]

    assert_equal [[3, 2]], movement_log.set_breakdown_rounds
  end
end
