require 'test_helper'

class SugarwodImport
  class RowImporterTest < ActiveSupport::TestCase
    setup { @user = users(:mathew) }

    test 'matches an existing catalog workout by name and creates a Log' do
      row = { date: Date.new(2018, 1, 2), title: 'Fran', description: '21-15-9 reps for time of:• Thruster 95/65#• Pull-ups',
              best_result_raw: '378', best_result_display: '6:18', score_type: '', barbell_lift: nil, notes: 'felt strong' }

      result = RowImporter.call(row, user: @user)

      assert_equal :imported, result.status
      log = @user.logs.find_by!(workout: workouts(:fran))
      assert_equal 378, log.score_value
      assert_equal 'felt strong', log.notes
      assert_equal Date.new(2018, 1, 2), log.created_at.to_date
    end

    test 'builds a single-exercise workout and one PR-tracking MovementLog for a simple barbell-lift row' do
      row = { date: Date.new(2020, 2, 10), title: 'Back Squat', description: 'Build to Heavy Single',
              best_result_raw: '205', best_result_display: '205', score_type: 'Load', barbell_lift: 'Back Squat',
              set_details: '[{"success":true,"load":205}]', notes: nil }

      result = RowImporter.call(row, user: @user)

      assert_equal :imported, result.status
      log = @user.logs.last
      assert_equal 205, log.score_value
      exercise = log.workout.exercises_for_log_recording.sole
      assert_equal 1, exercise.reps
      assert_equal movements(:back_squat), exercise.movement
      movement_log = log.movement_logs.sole
      assert_equal movements(:back_squat), movement_log.movement
      assert_equal 205, movement_log.load
    end

    test 'builds one MovementLog per successful set for a varying pyramid scheme' do
      row = { date: Date.new(2020, 2, 11), title: 'Front Squat 3-1-3-1-3-1-12', description: '',
              best_result_raw: '185', best_result_display: '185', score_type: 'Load', barbell_lift: 'Front Squat',
              set_details: '[{"success":true,"load":155},{"success":true,"load":165},{"success":true,"load":155},' \
                           '{"success":true,"load":175},{"success":true,"load":155},{"success":true,"load":185},' \
                           '{"success":true,"load":125}]', notes: nil }

      result = RowImporter.call(row, user: @user)

      assert_equal :imported, result.status
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

      result = RowImporter.call(row, user: @user)

      assert_equal :imported, result.status
      log = @user.logs.last
      assert_equal 215, log.score_value
      assert_equal 4, log.movement_logs.size
      assert_not_includes log.movement_logs.map(&:load), 225
    end

    test 'skips a barbell-lift row when the rep scheme cannot be aligned with set_details' do
      row = { date: Date.new(2020, 2, 13), title: 'Bench Press 4-2-4-2-4', description: '',
              best_result_raw: '205', best_result_display: '205', score_type: 'Load', barbell_lift: 'Bench Press',
              set_details: '[{"success":true,"load":155},{"success":true,"load":185},{"success":true,"load":155},' \
                           '{"success":true,"load":195},{"success":true,"load":155},{"success":true,"load":205}]',
              notes: nil }

      assert_equal :skipped, RowImporter.call(row, user: @user).status
    end

    test 'skips the PR-tracking MovementLogs for a weight-scored workout that totals more than one exercise' do
      row = { date: Date.new(2020, 4, 1), title: 'Total Test', description: 'For load:•Back Squat•Deadlift',
              best_result_raw: '500', best_result_display: '500', score_type: 'Load', barbell_lift: nil, notes: nil }

      result = RowImporter.call(row, user: @user)

      assert_equal :skipped, result.status
    end

    test 'skips a row with an unrecognized barbell_lift movement name' do
      row = { date: Date.new(2020, 5, 2), title: 'Some Lift', description: '', barbell_lift: 'Nonexistent Lift',
              best_result_raw: '600', score_type: 'Load', set_details: '[{"success":true,"load":600}]' }

      result = RowImporter.call(row, user: @user)

      assert_equal :skipped, result.status
    end

    test 'skips a row with a disregarded score_type without attempting to parse it' do
      row = { date: Date.new(2020, 1, 1), title: 'Daily Check-in', description: 'Did you stretch today?',
              best_result_raw: '1', best_result_display: 'Yes', score_type: 'Checkbox', barbell_lift: nil, notes: nil }

      result = RowImporter.call(row, user: @user)

      assert_equal :skipped, result.status
      assert_equal 'not a workout score type', result.reason
    end

    test 'skips a row with a blank best_result_raw without creating a Log' do
      row = { date: Date.new(2020, 6, 1), title: 'Fran', best_result_raw: '' }
      result = RowImporter.call(row, user: @user)

      assert_equal :skipped, result.status
      assert_equal 'no score recorded', result.reason
      assert_not @user.logs.exists?(workout: workouts(:fran))
    end

    test 'skips a row that matches no catalog workout, barbell lift, or single-modality shape' do
      row = { date: Date.new(2020, 3, 1), title: 'Row Burpee Chipper', description: 'For time:•50 Calorie Row•50 Push-ups',
              best_result_raw: '600', best_result_display: '10:00', score_type: '', barbell_lift: nil, notes: nil }

      result = RowImporter.call(row, user: @user)

      assert_equal :skipped, result.status
    end

    test 'rolls back a newly persisted Workout when create_log raises after resolve_workout succeeds' do
      row = { date: Date.new(2020, 7, 1), title: 'Back Squat', description: 'Build to Heavy Single',
              best_result_raw: '205', best_result_display: '205', score_type: 'Load', barbell_lift: 'Back Squat',
              set_details: '[{"success":true,"load":205}]', notes: nil }

      # Force a real failure inside create_log (ScoreMapper computes score_value before any
      # MovementLogs are built): an unrecognized load_display_unit makes LoadEquivalence.to_lb
      # raise ArgumentError, which propagates past RowImporter's own
      # `rescue ActiveRecord::ActiveRecordError` since it isn't one. What's under test is that
      # the transaction (now covering resolve_workout as well as create_log) still rolls back
      # the Workout that resolve_workout/persist newly saved, regardless of exception type.
      def @user.load_display_unit
        'furlongs'
      end

      assert_no_difference -> { Workout.count } do
        assert_raises(ArgumentError) { RowImporter.call(row, user: @user) }
      end
    end

    test 'does not assign set loads when the row-derived set count does not match an already-catalogued workout' do
      first_row = { date: Date.new(2020, 2, 11), title: 'Front Squat 3-1-3-1-3-1-12', description: '',
                    best_result_raw: '185', best_result_display: '185', score_type: 'Load', barbell_lift: 'Front Squat',
                    set_details: '[{"success":true,"load":155},{"success":true,"load":165},{"success":true,"load":155},' \
                                 '{"success":true,"load":175},{"success":true,"load":155},{"success":true,"load":185},' \
                                 '{"success":true,"load":125}]', notes: nil }
      RowImporter.call(first_row, user: @user)

      # Same title, so this second row is resolved via NameMatcher against the already-persisted
      # 7-exercise catalog workout above, not rebuilt via BarbellLiftBuilder. Its own set_details
      # still has 7 entries (so SetSchemeExtractor's scheme.size == details.size check passes),
      # but one is a failed attempt, so the filtered `sets` array it returns has only 6 elements --
      # a real mismatch against the persisted workout's 7 movement_logs.
      mismatched_row = first_row.merge(
        date: Date.new(2020, 2, 18),
        set_details: '[{"success":true,"load":155},{"success":true,"load":165},{"success":true,"load":155},' \
                     '{"success":true,"load":175},{"success":true,"load":155},{"success":true,"load":185},' \
                     '{"success":false,"load":225}]'
      )

      result = RowImporter.call(mismatched_row, user: @user)

      assert_equal :imported, result.status
      workout = Workout.find_by!(name: 'Front Squat 3-1-3-1-3-1-12')
      log = @user.logs.find_by!(workout: workout, created_at: Date.new(2020, 2, 18).all_day)
      assert_equal 7, log.movement_logs.size
      assert log.movement_logs.map(&:load).all?(&:nil?)
    end

    test 'is idempotent: re-importing the same user/workout/date does not create a duplicate Log' do
      row = { date: Date.new(2018, 1, 2), title: 'Fran', description: '21-15-9 reps for time of:• Thruster 95/65#• Pull-ups',
              best_result_raw: '378', best_result_display: '6:18', score_type: '', barbell_lift: nil, notes: nil }

      RowImporter.call(row, user: @user)
      result = RowImporter.call(row, user: @user)

      assert_equal :already_imported, result.status
      assert_equal 1, @user.logs.where(workout: workouts(:fran)).count
    end
  end
end
