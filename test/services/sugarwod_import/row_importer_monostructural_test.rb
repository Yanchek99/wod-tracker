require 'test_helper'

# Coverage for RowImporter's cascade wiring of MonostructuralDetector, the fallback that builds a
# single-movement distance-for-time or max-calorie Workout from a row/run/bike/ski row. Split out
# from row_importer_test.rb (which covers field mapping) to keep that class within
# Metrics/ClassLength.
class SugarwodImport
  class RowImporterMonostructuralTest < ActiveSupport::TestCase
    setup { @user = users(:mathew) }

    test 'imports a distance-for-time row via MonostructuralDetector, recording the real time' do
      row = { date: Date.new(2023, 8, 20), title: '800m Row', description: '800m Row',
              best_result_raw: '185', best_result_display: '3:05', score_type: 'Time', barbell_lift: '' }

      result = RowImporter.call(row, user: @user)

      assert_equal :imported, result.status
      log = @user.logs.find_by(workout: Workout.find_by(name: 'Row 800m'))
      assert_equal 185, log.score_value
      movement_log = log.movement_logs.sole
      assert_equal 185, movement_log.duration_seconds
    end
  end
end
