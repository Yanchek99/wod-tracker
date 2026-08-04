require 'test_helper'

# Coverage for RowImporter's cascade wiring of MaxDistanceDetector, the fallback that builds a
# distance-scored Workout from a single-movement "Max Height" achievement row. Split out from
# row_importer_test.rb (which covers field mapping) to keep that class within Metrics/ClassLength.
class SugarwodImport
  class RowImporterMaxDistanceTest < ActiveSupport::TestCase
    setup { @user = users(:mathew) }

    test 'imports a max-height row via MaxDistanceDetector' do
      Movement.find_or_create_by(name: 'Box Jump')
      row = { date: Date.new(2023, 9, 14), title: 'Box Jump: Max Height', description: 'Box Jump: Max Height',
              best_result_raw: '44', best_result_display: '44', score_type: 'Inches', barbell_lift: '' }

      result = RowImporter.call(row, user: @user)

      assert_equal :imported, result.status
      log = @user.logs.find_by(workout: Workout.find_by(name: 'Max Box Jump Height'))
      assert_equal 44, log.score_value
    end
  end
end
