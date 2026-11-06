require 'test_helper'

# Reliability regression coverage for RowImporter's transaction boundary and its guard against
# mismatched set/movement-log counts. Split out from row_importer_test.rb (which covers field
# mapping) to keep that class within Metrics/ClassLength.
class SugarwodImport
  class RowImporterTransactionTest < ActiveSupport::TestCase
    setup { @user = users(:mathew) }

    # ScoreMapper computes score_value (which can raise) before any MovementLogs are built, so an
    # unrecognized load_display_unit makes LoadEquivalence.to_lb raise ArgumentError -- a real
    # failure inside create_log that isn't an ActiveRecordError, so it propagates past
    # RowImporter's own rescue. Proves the transaction (now covering resolve_workout too) still
    # rolls back the Workout that resolve_workout/persist newly saved, regardless of exception type.
    test 'rolls back a newly persisted Workout when create_log raises after resolve_workout succeeds' do
      row = { date: Date.new(2020, 7, 1), title: 'Back Squat', description: 'Build to Heavy Single',
              best_result_raw: '205', best_result_display: '205', score_type: 'Load', barbell_lift: 'Back Squat',
              set_details: sets_json([true, 205]), notes: nil }
      def @user.load_display_unit = 'furlongs'

      assert_no_difference -> { Workout.count } do
        assert_raises(ArgumentError) { RowImporter.call(row, user: @user) }
      end
    end

    # Same title, so the second row is resolved via NameMatcher against the already-persisted
    # 7-exercise catalog workout, not rebuilt via BarbellLiftBuilder. Its own set_details still has
    # 7 entries (so SetSchemeExtractor's scheme.size == details.size check passes), but one is a
    # failed attempt, so the filtered `sets` it returns has only 6 elements -- a real mismatch
    # against the persisted workout's 7 movement_logs.
    test 'does not assign set loads when the row-derived set count does not match an already-catalogued workout' do
      shared_sets = [155, 165, 155, 175, 155, 185].map { |load| [true, load] }
      first_row = { date: Date.new(2020, 2, 11), title: 'Front Squat 3-1-3-1-3-1-12', description: '',
                    best_result_raw: '185', best_result_display: '185', score_type: 'Load', barbell_lift: 'Front Squat',
                    notes: nil, set_details: sets_json(*shared_sets, [true, 125]) }
      RowImporter.call(first_row, user: @user)
      mismatched_row = first_row.merge(date: Date.new(2020, 2, 18), set_details: sets_json(*shared_sets, [false, 225]))

      result = RowImporter.call(mismatched_row, user: @user)

      assert_equal :imported, result.status
      workout = Workout.find_by!(name: 'Front Squat 3-1-3-1-3-1-12')
      log = @user.logs.find_by!(workout: workout, created_at: Date.new(2020, 2, 18).all_day)
      assert_equal 7, log.movement_logs.size
      assert log.movement_logs.map(&:load).all?(&:nil?)
    end

    private

    def sets_json(*success_and_load_pairs)
      success_and_load_pairs.map { |success, load| { success: success, load: load } }.to_json
    end
  end
end
