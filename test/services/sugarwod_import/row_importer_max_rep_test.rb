require 'test_helper'

# Coverage for RowImporter's cascade wiring of MaxRepDetector, the fallback that builds a
# rep-scored Workout from a single-movement "max reps" achievement row. Split out from
# row_importer_test.rb (which covers field mapping) to keep that class within Metrics/ClassLength.
class SugarwodImport
  class RowImporterMaxRepTest < ActiveSupport::TestCase
    setup { @user = users(:mathew) }

    test 'imports a max-reps row via MaxRepDetector, replacing the reps: 0 sentinel with the real count' do
      Movement.find_or_create_by(name: 'Toes to Bar')
      row = { date: Date.new(2023, 9, 14), title: 'Max Toes to Bar', description: 'Max Toes to Bar',
              best_result_raw: '48', best_result_display: '48', score_type: 'Reps', barbell_lift: '' }

      result = RowImporter.call(row, user: @user)

      assert_equal :imported, result.status
      log = @user.logs.find_by(workout: Workout.find_by(name: 'Max Toes to Bar'))
      assert_equal 48, log.score_value
      movement_log = log.movement_logs.sole
      assert_equal 48, movement_log.reps
    end
  end
end
