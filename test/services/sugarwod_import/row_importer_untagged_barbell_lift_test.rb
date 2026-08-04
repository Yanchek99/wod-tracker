require 'test_helper'

# Coverage for RowImporter's cascade wiring of UntaggedBarbellLiftDetector, the fallback that
# builds a barbell-lift Workout from a single unambiguous movement named in the title or
# description of a row SugarWOD never tagged with barbell_lift. Split out from row_importer_test.rb
# (which covers field mapping) to keep that class within Metrics/ClassLength.
class SugarwodImport
  class RowImporterUntaggedBarbellLiftTest < ActiveSupport::TestCase
    setup { @user = users(:mathew) }

    test 'imports an untagged single-lift row via UntaggedBarbellLiftDetector' do
      row = { date: Date.new(2023, 1, 5), title: 'Back Squat', description: 'For Total Load: 5 Sets of 5',
              best_result_raw: '225', best_result_display: '225', score_type: 'Load', barbell_lift: '',
              set_details: '[{"success":true,"load":225}]' }

      result = RowImporter.call(row, user: @user)

      assert_equal :imported, result.status
      assert @user.logs.exists?(workout: Workout.find_by(name: 'Back Squat 5'))
    end
  end
end
