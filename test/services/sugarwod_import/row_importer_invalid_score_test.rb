require 'test_helper'

# Coverage for RowImporter's handling of a row whose best_result_raw can't become a real score --
# blank, or text ScoreMapper can't parse for the workout's score type. Split out from
# row_importer_test.rb (which covers field mapping) to keep that class within Metrics/ClassLength.
class SugarwodImport
  class RowImporterInvalidScoreTest < ActiveSupport::TestCase
    setup { @user = users(:mathew) }

    test 'skips a row with a blank best_result_raw without creating a Log' do
      row = { date: Date.new(2020, 6, 1), title: 'Fran', best_result_raw: '' }
      result = RowImporter.call(row, user: @user)

      assert_equal :skipped, result.status
      assert_equal 'no score recorded', result.reason
      assert_not @user.logs.exists?(workout: workouts(:fran))
    end

    test 'skips a row with a non-numeric best_result_raw instead of fabricating a zero score' do
      row = { date: Date.new(2020, 6, 2), title: 'Fran', description: '21-15-9 reps for time of:• Thruster 95/65#• Pull-ups',
              best_result_raw: 'not recorded', best_result_display: 'not recorded', score_type: '', barbell_lift: nil }

      result = RowImporter.call(row, user: @user)

      assert_equal :skipped, result.status
      assert_not @user.logs.exists?(workout: workouts(:fran))
    end
  end
end
