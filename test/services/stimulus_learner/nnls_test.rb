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

    test 'terminates on duplicate columns' do
      rows = [[21.0, 21.0, 400.0], [15.0, 15.0, 200.0], [9.0, 9.0, 800.0]]

      solution = Timeout.timeout(2) { Nnls.solve(rows, [120.0, 90.0, 260.0]) }

      assert(solution.all? { |value| value.finite? && value >= 0 })
    end

    test 'terminates with more columns than rows at real volume scales' do
      rows = [[63.0, 1200.0, 0.0, 30.0, 0.0, 15.0],
              [105.0, 1000.0, 50.0, 0.0, 21.0, 0.0],
              [20.0, 1600.0, 0.0, 45.0, 0.0, 30.0],
              [50.0, 0.0, 100.0, 0.0, 42.0, 0.0]]

      solution = Timeout.timeout(2) { Nnls.solve(rows, [486.0, 510.0, 520.0, 100.0]) }

      assert(solution.all? { |value| value.finite? && value >= 0 })
    end

    test 'terminates on random rank-deficient systems' do
      random = Random.new(1992)
      200.times do
        base = Array.new(4) { Array.new(3) { random.rand(0.0..500.0) } }
        rows = base.map { |row| row + [row[0] * 2, row[1] + row[2]] }
        targets = Array.new(4) { random.rand(50.0..1500.0) }

        solution = Timeout.timeout(2) { Nnls.solve(rows, targets) }

        assert(solution.all? { |value| value.finite? && value >= 0 })
      end
    end
  end
end
