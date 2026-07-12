require 'test_helper'

module CfWorkout
  class PrescriptionClauseParserTest < ActiveSupport::TestCase
    test 'parses a legacy Men:/Women: bare-weight block with no implement noun' do
      result = PrescriptionClauseParser.call("Men: 95 lb.\nWomen: 65 lb.")

      assert_equal [[{ value: 65, unit: :lb, implement: '' }]], result[:female]
      assert_equal [[{ value: 95, unit: :lb, implement: '' }]], result[:male]
    end

    test 'parses a modern multi-clause block with implement nouns' do
      female = '♀ 185-lb barbell, 20-inch box, and 14-lb medicine ball to a 9-foot target'
      male = '♂ 275-lb barbell, 24-inch box, and 20-lb medicine ball to a 10-foot target'

      result = PrescriptionClauseParser.call("#{female}\n#{male}")

      assert_equal 3, result[:female].length
      assert_equal [{ value: 185, unit: :lb, implement: 'barbell' }], result[:female][0]
      assert_equal [{ value: 20, unit: :inch, implement: 'box' }], result[:female][1]
      assert_equal [{ value: 14, unit: :lb, implement: 'medicine ball' },
                    { value: 9, unit: :foot, implement: 'target' }], result[:female][2]
      assert_equal [{ value: 275, unit: :lb, implement: 'barbell' }], result[:male][0]
    end

    test 'parses Female:/Male: prefixes' do
      result = PrescriptionClauseParser.call("Female 2-inch deficit\nMale 4-inch deficit")

      assert_equal [[{ value: 2, unit: :inch, implement: 'deficit' }]], result[:female]
      assert_equal [[{ value: 4, unit: :inch, implement: 'deficit' }]], result[:male]
    end

    test 'parses whole-number kg values as integers' do
      result = PrescriptionClauseParser.call("Men: 61 kg.\nWomen: 43 kg.")

      assert_equal [[{ value: 43, unit: :kg, implement: '' }]], result[:female]
      assert_equal [[{ value: 61, unit: :kg, implement: '' }]], result[:male]
    end

    test 'preserves decimal precision for kg values' do
      result = PrescriptionClauseParser.call("Men: 38.5 kg.\nWomen: 22.5 kg.")

      assert_equal [[{ value: 22.5, unit: :kg, implement: '' }]], result[:female]
      assert_equal [[{ value: 38.5, unit: :kg, implement: '' }]], result[:male]
    end

    test 'parses pood values' do
      result = PrescriptionClauseParser.call("Men: 2 pood.\nWomen: 1.5 pood.")

      assert_equal [[{ value: 1.5, unit: :pood, implement: '' }]], result[:female]
      assert_equal [[{ value: 2, unit: :pood, implement: '' }]], result[:male]
    end
  end
end
