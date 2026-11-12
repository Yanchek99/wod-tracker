require 'test_helper'

module StimulusLearner
  class NnlsTest < ActiveSupport::TestCase
    test 'recovers known non-negative coefficients' do
      rows = [[1.0, 0.0], [0.0, 1.0], [1.0, 1.0]]
      targets = [2.0, 3.0, 5.0]

      solution = Nnls.solve(rows, targets)

      assert_in_delta 2.0, solution[0], 1e-6
      assert_in_delta 3.0, solution[1], 1e-6
    end

    test 'clamps a would-be negative coefficient to zero' do
      rows = [[1.0, 1.0], [1.0, 2.0], [1.0, 3.0]]
      targets = [3.0, 2.0, 1.0] # unconstrained slope is -1

      solution = Nnls.solve(rows, targets)

      assert_in_delta 0.0, solution[1], 1e-9
      assert_operator solution[0], :>, 0
    end
  end
end
