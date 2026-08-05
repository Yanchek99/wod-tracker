require 'test_helper'

class SugarwodImport
  class ScoreMapperTest < ActiveSupport::TestCase
    test 'maps a time-scored workout to whole seconds' do
      row = { best_result_raw: '378', best_result_display: '6:18', notes: 'felt good' }
      attrs = ScoreMapper.call(workouts(:fran), row, user: users(:mathew))
      assert_equal({ score_type: 'time', score_value: 378, notes: 'felt good' }, attrs)
    end

    test "converts a load-scored workout from the user's display unit to canonical pounds" do
      metric_user = users(:mathew)
      metric_user.update!(unit_system: :metric)
      row = { best_result_raw: '100', best_result_display: '100', notes: nil }
      attrs = ScoreMapper.call(workouts(:back_squat_5x5), row, user: metric_user)
      assert_equal 220, attrs[:score_value]
    end

    test 'parses a rounds+reps display string for a rep-scored AMRAP workout' do
      row = { best_result_raw: '6.054', best_result_display: '6+54', notes: nil }
      attrs = ScoreMapper.call(workouts(:amrap_couplet), row, user: users(:mathew))
      assert_equal '6+54', attrs[:score_value]
    end

    test 'falls back to a plain integer for a rep-scored workout with no rounds+reps display' do
      row = { best_result_raw: '241', best_result_display: '241', notes: nil }
      attrs = ScoreMapper.call(workouts(:amrap_couplet), row, user: users(:mathew))
      assert_equal 241, attrs[:score_value]
    end

    test 'returns nil for a non-numeric best_result_raw instead of coercing it to zero' do
      row = { best_result_raw: 'not recorded', best_result_display: 'not recorded', notes: nil }
      assert_nil ScoreMapper.call(workouts(:fran), row, user: users(:mathew))
    end

    test 'returns nil for a non-numeric load on a weight-scored workout' do
      row = { best_result_raw: 'abc123', best_result_display: 'abc123', notes: nil }
      assert_nil ScoreMapper.call(workouts(:back_squat_5x5), row, user: users(:mathew))
    end

    test 'returns nil for a non-numeric best_result_raw on a rep-scored workout' do
      row = { best_result_raw: 'DNF', best_result_display: 'DNF', notes: nil }
      assert_nil ScoreMapper.call(workouts(:amrap_couplet), row, user: users(:mathew))
    end
  end
end
