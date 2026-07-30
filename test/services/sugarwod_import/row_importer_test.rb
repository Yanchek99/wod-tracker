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

    test 'builds a single-exercise workout and a PR-tracking MovementLog for a barbell-lift row' do
      row = { date: Date.new(2020, 2, 10), title: 'Back Squat', description: 'Build to Heavy Single',
              best_result_raw: '205', best_result_display: '205', score_type: 'Load', barbell_lift: 'Back Squat',
              notes: nil }

      result = RowImporter.call(row, user: @user)

      assert_equal :imported, result.status
      log = @user.logs.last
      assert_equal 205, log.score_value
      exercise = log.workout.exercises_for_log_recording.sole
      assert_equal movements(:back_squat), exercise.movement
      movement_log = log.movement_logs.sole
      assert_equal movements(:back_squat), movement_log.movement
      assert_equal 205, movement_log.load
    end

    test 'skips the PR-tracking MovementLog for a weight-scored workout that totals more than one exercise' do
      row = { date: Date.new(2020, 4, 1), title: 'Total Test', description: 'For load:•Back Squat•Deadlift',
              best_result_raw: '500', best_result_display: '500', score_type: 'Load', barbell_lift: nil, notes: nil }

      result = RowImporter.call(row, user: @user)

      assert_equal :imported, result.status
      log = @user.logs.last
      assert_equal 'weight', log.workout.score_type
      assert_equal 2, log.workout.exercises_for_log_recording.size
      assert_empty log.movement_logs
    end

    test 'parses a workout via the heuristic parser when no catalog name matches' do
      row = { date: Date.new(2020, 3, 1), title: 'Row Burpee Chipper', description: 'For time:•50 Calorie Row•50 Push-ups',
              best_result_raw: '600', best_result_display: '10:00', score_type: '', barbell_lift: nil, notes: nil }

      result = RowImporter.call(row, user: @user)

      assert_equal :imported, result.status
      workout = @user.logs.last.workout
      assert_equal 'time', workout.score_type
      movements_used = workout.exercises.map(&:movement)
      assert_includes movements_used, movements(:row)
      assert_includes movements_used, movements(:pushup)
    end

    test 'falls back to the LLM parser when the heuristic parser cannot classify the header' do
      row = { date: Date.new(2020, 2, 4), title: 'Strict Gymnastics', description: 'Some totally novel coaching shorthand',
              best_result_raw: '19', best_result_display: '19', score_type: 'Reps', barbell_lift: nil, notes: nil }

      result = stub_llm_parser(workouts(:fran)) { RowImporter.call(row, user: @user) }

      assert_equal :imported, result.status
      assert_equal workouts(:fran), @user.logs.last.workout
    end

    test 'skips a row with a disregarded score_type without attempting to parse it' do
      row = { date: Date.new(2020, 1, 1), title: 'Daily Check-in', description: 'Did you stretch today?',
              best_result_raw: '1', best_result_display: 'Yes', score_type: 'Checkbox', barbell_lift: nil, notes: nil }

      result = RowImporter.call(row, user: @user)

      assert_equal :skipped, result.status
      assert_equal 'not a workout score type', result.reason
    end

    test 'skips a row when both the heuristic and LLM parser fail, recording the failure reason' do
      row = { date: Date.new(2020, 2, 4), title: 'Bubbles', description: 'A totally freeform multi-block session',
              best_result_raw: '12', best_result_display: '12', score_type: 'Rounds + Reps', barbell_lift: nil, notes: nil }

      result = stub_llm_parser(->(*, **) { raise WorkoutExtraction::LlmParser::ExtractionError, 'llm boom' }) do
        RowImporter.call(row, user: @user)
      end

      assert_equal :skipped, result.status
      assert_equal 'llm boom', result.reason
    end

    test 'falls through to the heuristic parser when the barbell_lift name is not in the movement catalog' do
      row = { date: Date.new(2020, 5, 2), title: 'Row Burpee Chipper', description: 'For time:•50 Calorie Row•50 Push-ups',
              best_result_raw: '600', barbell_lift: 'Nonexistent Lift' }
      result = RowImporter.call(row, user: @user)

      assert_equal :imported, result.status
      workout = @user.logs.last.workout
      assert_equal 'time', workout.score_type
    end

    test 'skips a row with a blank best_result_raw without creating a Log' do
      row = { date: Date.new(2020, 6, 1), title: 'Fran', best_result_raw: '' }
      result = RowImporter.call(row, user: @user)

      assert_equal :skipped, result.status
      assert_equal 'no score recorded', result.reason
      assert_not @user.logs.exists?(workout: workouts(:fran))
    end

    test 'rolls back a newly persisted Workout when create_log raises after resolve_workout succeeds' do
      row = { date: Date.new(2020, 7, 1), title: 'Totally Novel Max Pullup AMRAP',
              description: 'As many rounds and reps as possible in 12 minutes of:•Max Pull-ups', best_result_raw: '6.054',
              best_result_display: '6+54' }

      assert_no_difference -> { Workout.count } do
        assert_equal :skipped, RowImporter.call(row, user: @user).status
      end
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
