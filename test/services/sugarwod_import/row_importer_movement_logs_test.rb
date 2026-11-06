require 'test_helper'

# Coverage for RowImporter's "total" shape: a weight-scored workout whose exercises are each a
# distinct movement with one set_details entry apiece (e.g. a 1-rep-max clean + bench press +
# overhead squat), as opposed to repeated sets of a single movement. Split out from
# row_importer_test.rb (which covers field mapping) to keep that class within Metrics/ClassLength.
class SugarwodImport
  class RowImporterMovementLogsTest < ActiveSupport::TestCase
    setup { @user = users(:mathew) }

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

    # Same 3-movement shape and same 3-successful-load count as the row above, but a 4th (failed)
    # raw set_details entry means there were 4 total attempts across 3 movements -- e.g. a missed
    # first clean attempt logged as its own entry. The 3 successful loads no longer correspond
    # 1:1 with the 3 movements (they could be 2 clean attempts + 1 bench press, with the overhead
    # squat attempt never recorded), so pairing them positionally would misattribute a load to the
    # wrong movement and corrupt that movement's PR history. Never guess: skip instead.
    test 'skips a multi-lift total when raw set_details has more attempts than movements' do
      workout = Workout.create!(name: 'Quarterfinals 22.4 Retry', score_type: :weight)
      segment = workout.segments.create!(position: 1)
      segment.exercises.create!(movement: movements(:clean), position: 1, reps: 1)
      segment.exercises.create!(movement: movements(:bench_press), position: 2, reps: 1)
      segment.exercises.create!(movement: movements(:overhead_squat), position: 3, reps: 1)

      row = { date: Date.new(2022, 3, 25), title: 'Quarterfinals 22.4 Retry',
              description: '1 clean1 bench press1 overhead squat',
              best_result_raw: '640', best_result_display: '640', score_type: 'Load', barbell_lift: '',
              set_details: '[{"success":false,"load":220},{"success":true,"load":230},' \
                           '{"success":true,"load":215},{"success":true,"load":195}]' }

      result = RowImporter.call(row, user: @user)

      assert_equal :imported, result.status
      log = @user.logs.find_by(workout: workout)
      assert_predicate log.movement_logs, :empty?
    end
  end
end
