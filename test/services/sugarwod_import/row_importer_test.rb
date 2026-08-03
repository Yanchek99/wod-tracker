require 'test_helper'

class SugarwodImport
  class RowImporterTest < ActiveSupport::TestCase
    setup { @user = users(:mathew) }

    test 'matches an existing catalog workout by name and creates a Log' do
      row = { date: Date.new(2018, 1, 2), title: 'Fran', description: '21-15-9 reps for time of:• Thruster 95/65#• Pull-ups',
              best_result_raw: '378', best_result_display: '6:18', score_type: '', barbell_lift: nil, notes: 'felt strong' }

      assert_equal :imported, RowImporter.call(row, user: @user).status
      log = @user.logs.find_by!(workout: workouts(:fran))
      assert_equal [378, 'felt strong', Date.new(2018, 1, 2)], [log.score_value, log.notes, log.created_at.to_date]
    end

    test 'builds a single-exercise workout and one PR-tracking MovementLog for a simple barbell-lift row' do
      row = { date: Date.new(2020, 2, 10), title: 'Back Squat', description: 'Build to Heavy Single', best_result_raw: '205',
              best_result_display: '205', score_type: 'Load', barbell_lift: 'Back Squat', set_details: '[{"success":true,"load":205}]', notes: nil }

      assert_equal :imported, RowImporter.call(row, user: @user).status
      log = @user.logs.last
      assert_equal 205, log.score_value
      exercise = log.workout.exercises_for_log_recording.sole
      assert_equal [1, movements(:back_squat)], [exercise.reps, exercise.movement]
      movement_log = log.movement_logs.sole
      assert_equal [movements(:back_squat), 205], [movement_log.movement, movement_log.load]
    end

    test 'builds one MovementLog per successful set for a varying pyramid scheme' do
      row = { date: Date.new(2020, 2, 11), title: 'Front Squat 3-1-3-1-3-1-12', description: '', best_result_raw: '185',
              best_result_display: '185', score_type: 'Load', barbell_lift: 'Front Squat',
              set_details: '[{"success":true,"load":155},{"success":true,"load":165},{"success":true,"load":155},{"success":true,"load":175},{"success":true,' \
                           '"load":155},{"success":true,"load":185},{"success":true,"load":125}]', notes: nil }

      assert_equal :imported, RowImporter.call(row, user: @user).status
      log = @user.logs.last
      assert_equal 185, log.score_value
      assert_equal 7, log.movement_logs.size
      assert_equal [3, 1, 3, 1, 3, 1, 12], log.movement_logs.map(&:reps)
      assert_equal [155, 165, 155, 175, 155, 185, 125], log.movement_logs.map(&:load)
    end

    test 'excludes a failed attempt from the recorded MovementLogs' do
      row = { date: Date.new(2020, 2, 12), title: 'Power Clean 1-1-1-1-1', description: '',
              best_result_raw: '215', best_result_display: '215', score_type: 'Load', barbell_lift: 'Power Clean',
              set_details: '[{"success":true,"load":175},{"success":true,"load":185},{"success":true,"load":205},' \
                           '{"success":true,"load":215},{"success":false,"load":225}]', notes: nil }

      assert_equal :imported, RowImporter.call(row, user: @user).status
      log = @user.logs.last
      assert_equal 215, log.score_value
      assert_equal 4, log.movement_logs.size
      assert_not_includes log.movement_logs.map(&:load), 225
    end

    test 'builds one MovementLog per distinct movement for a multi-lift total, pairing loads by position' do
      workout = Workout.create!(name: 'Quarterfinals 22.4', score_type: :weight)
      segment = workout.segments.create!(position: 1)
      clean_exercise = segment.exercises.create!(movement: movements(:clean), position: 1, reps: 1)
      bench_press_exercise = segment.exercises.create!(movement: movements(:bench_press), position: 2, reps: 1)
      overhead_squat_exercise = segment.exercises.create!(movement: movements(:overhead_squat), position: 3, reps: 1)

      row = { date: Date.new(2022, 3, 25), title: 'Quarterfinals 22.4', description: '1 clean1 bench press1 overhead squat',
              best_result_raw: '640', best_result_display: '640', score_type: 'Load', barbell_lift: '',
              set_details: '[{"success":true,"load":230},{"success":true,"load":215},{"success":true,"load":195}]' }

      result = RowImporter.call(row, user: @user)

      assert_equal :imported, result.status
      log = @user.logs.find_by(workout: workout)
      loads = log.movement_logs.order(:id).pluck(:movement_id, :load).to_h
      assert_equal 230, loads[clean_exercise.movement_id]
      assert_equal 215, loads[bench_press_exercise.movement_id]
      assert_equal 195, loads[overhead_squat_exercise.movement_id]
    end

    test 'skips a barbell-lift row when the rep scheme cannot be aligned with set_details' do
      row = { date: Date.new(2020, 2, 13), title: 'Bench Press 4-2-4-2-4', description: '', best_result_raw: '205',
              best_result_display: '205', score_type: 'Load', barbell_lift: 'Bench Press',
              set_details: '[{"success":true,"load":155},{"success":true,"load":185},{"success":true,"load":155},{"success":true,"load":195},{"success":true,' \
                           '"load":155},{"success":true,"load":205}]', notes: nil }

      assert_equal :skipped, RowImporter.call(row, user: @user).status
    end

    test 'skips the PR-tracking MovementLogs for a weight-scored workout that totals more than one exercise' do
      row = { date: Date.new(2020, 4, 1), title: 'Total Test', description: 'For load:•Back Squat•Deadlift',
              best_result_raw: '500', best_result_display: '500', score_type: 'Load', barbell_lift: nil, notes: nil }

      assert_equal :skipped, RowImporter.call(row, user: @user).status
    end

    test 'skips a row with an unrecognized barbell_lift movement name' do
      row = { date: Date.new(2020, 5, 2), title: 'Some Lift', description: '', barbell_lift: 'Nonexistent Lift',
              best_result_raw: '600', score_type: 'Load', set_details: '[{"success":true,"load":600}]' }

      assert_equal :skipped, RowImporter.call(row, user: @user).status
    end

    test 'skips a row with a disregarded score_type without attempting to parse it' do
      row = { date: Date.new(2020, 1, 1), title: 'Daily Check-in', description: 'Did you stretch today?',
              best_result_raw: '1', best_result_display: 'Yes', score_type: 'Checkbox', barbell_lift: nil, notes: nil }

      result = RowImporter.call(row, user: @user)

      assert_equal [:skipped, 'not a workout score type'], [result.status, result.reason]
    end

    test 'skips a row with a blank best_result_raw without creating a Log' do
      row = { date: Date.new(2020, 6, 1), title: 'Fran', best_result_raw: '' }
      result = RowImporter.call(row, user: @user)

      assert_equal [:skipped, 'no score recorded'], [result.status, result.reason]
      assert_not @user.logs.exists?(workout: workouts(:fran))
    end

    test 'skips a row that matches no catalog workout, barbell lift, or single-modality shape' do
      row = { date: Date.new(2020, 3, 1), title: 'Row Burpee Chipper', description: 'For time:•50 Calorie Row•50 Push-ups',
              best_result_raw: '600', best_result_display: '10:00', score_type: '', barbell_lift: nil, notes: nil }

      assert_equal :skipped, RowImporter.call(row, user: @user).status
    end

    test 'is idempotent: re-importing the same user/workout/date does not create a duplicate Log' do
      row = { date: Date.new(2018, 1, 2), title: 'Fran', description: '21-15-9 reps for time of:• Thruster 95/65#• Pull-ups',
              best_result_raw: '378', best_result_display: '6:18', score_type: '', barbell_lift: nil, notes: nil }

      RowImporter.call(row, user: @user)

      assert_equal :already_imported, RowImporter.call(row, user: @user).status
      assert_equal 1, @user.logs.where(workout: workouts(:fran)).count
    end
  end
end
