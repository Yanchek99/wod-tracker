module StimulusLearner
  # Non-negative least squares (Lawson-Hanson active-set method) in plain Ruby: minimizes
  # |A x - b| subject to x >= 0. Sized for the learner's small systems (tens of columns), so the
  # inner unconstrained solves use normal equations with Gaussian elimination. (The `matrix`
  # gem is only bundled for tests, so production can't lean on it.)
  module Nnls
    MAX_ITERATIONS = 500
    # Relative ridge added to the normal equations' diagonal so duplicate or collinear columns
    # stay solvable instead of producing a singular system.
    RIDGE = 1e-9

    module_function

    # Every loop is bounded: the outer loop by MAX_ITERATIONS, the inner one because each pass
    # drops at least one column from the passive set. A column that falls straight back out right
    # after joining is not retried, which stops add/drop cycling on degenerate systems.
    def solve(rows, targets)
      solution = Array.new(rows.first&.size.to_i, 0.0)
      tolerance = tolerance(rows, targets)
      passive = []
      rejected = []
      MAX_ITERATIONS.times do
        candidate = next_column(rows, targets, solution, passive + rejected, tolerance)
        break unless candidate

        passive << candidate
        solution = refine(rows, targets, solution, passive, tolerance)
        rejected << candidate unless passive.include?(candidate)
      end
      solution.map { |value| value.finite? && value > tolerance ? value : 0.0 }
    end

    # Scale-aware zero: the data's magnitude decides what counts as zero.
    def tolerance(rows, targets)
      scale = [rows.flatten.map(&:abs).max.to_f, targets.map(&:abs).max.to_f, 1.0].max
      scale * rows.size * 1e-12
    end

    # The inactive column whose gradient most wants to grow, or nil once none does.
    def next_column(rows, targets, solution, excluded, tolerance)
      gradient = gradient(rows, targets, solution)
      candidate = solution.each_index.reject { |j| excluded.include?(j) }.max_by { |j| gradient[j] }
      candidate if candidate && gradient[candidate] > tolerance
    end

    # Solve on the passive set; while the unconstrained answer is not positive, step back toward
    # feasibility, zero the blocking column(s) and drop them.
    def refine(rows, targets, solution, passive, tolerance)
      passive.size.times do
        trial = least_squares(rows, targets, passive, solution.size)
        return trial if passive.all? { |j| trial[j] > tolerance }

        solution = step_toward(solution, trial, passive, tolerance)
        passive.reject! { |j| solution[j] <= tolerance }
        return solution if passive.empty?
      end
      solution
    end

    # Moves from solution toward trial as far as feasibility allows, and zeroes every passive
    # column that is non-positive at that point (always at least the blocking one).
    def step_toward(solution, trial, passive, tolerance)
      blocked = passive.select { |j| trial[j] <= tolerance }
      step = feasible_step(solution, trial, blocked, tolerance)
      moved = solution.each_index.map { |j| solution[j] + ((step || 0.0) * (trial[j] - solution[j])) }
      blocked.each { |j| moved[j] = 0.0 if step.nil? || moved[j] <= tolerance }
      moved
    end

    # The largest step that keeps every blocked column non-negative; nil when no blocked column
    # can move (e.g. a column already at zero whose trial value is also zero).
    def feasible_step(solution, trial, blocked, tolerance)
      blocked.filter_map do |j|
        denominator = solution[j] - trial[j]
        solution[j] / denominator if denominator > tolerance
      end.min
    end

    def gradient(rows, targets, solution)
      residuals = rows.each_with_index.map { |row, i| targets[i] - dot(row, solution) }
      solution.each_index.map { |j| rows.each_with_index.sum { |row, i| row[j] * residuals[i] } }
    end

    def least_squares(rows, targets, passive, columns)
      values = gaussian(normal_matrix(rows, passive), normal_rhs(rows, targets, passive))
      Array.new(columns, 0.0).tap { |full| passive.each_with_index { |j, k| full[j] = values[k] } }
    end

    def normal_matrix(rows, passive)
      matrix = passive.map { |a| passive.map { |b| rows.sum { |row| row[a] * row[b] } } }
      ridge = RIDGE * [matrix.each_with_index.map { |row, i| row[i] }.max.to_f, 1.0].max
      matrix.each_with_index { |row, i| row[i] += ridge }
    end

    def normal_rhs(rows, targets, passive)
      passive.map { |a| rows.each_with_index.sum { |row, i| row[a] * targets[i] } }
    end

    def gaussian(matrix, rhs)
      augmented = matrix.each_with_index.map { |row, i| row.map(&:to_f) + [rhs[i].to_f] }
      rhs.size.times { |col| eliminate(augmented, col) }
      back_substitute(augmented, rhs.size)
    end

    def eliminate(augmented, col)
      pivot_row = swap_pivot(augmented, col)
      return if pivot_row[col].abs < Float::EPSILON

      ((col + 1)...augmented.size).each do |r|
        augmented[r] = subtract_scaled(augmented[r], pivot_row, augmented[r][col] / pivot_row[col])
      end
    end

    # Partial pivoting: move the row with the largest entry in this column up to it.
    def swap_pivot(augmented, col)
      pivot = (col...augmented.size).max_by { |r| augmented[r][col].abs }
      augmented[col], augmented[pivot] = augmented[pivot], augmented[col]
      augmented[col]
    end

    def subtract_scaled(row, pivot_row, factor)
      row.each_with_index.map { |value, c| value - (factor * pivot_row[c]) }
    end

    def back_substitute(augmented, size)
      values = Array.new(size, 0.0)
      (size - 1).downto(0) do |r|
        next if augmented[r][r].abs < Float::EPSILON

        known = ((r + 1)...size).sum { |c| augmented[r][c] * values[c] }
        values[r] = (augmented[r][size] - known) / augmented[r][r]
      end
      values
    end

    def dot(row, solution)
      row.each_with_index.sum { |value, j| value * solution[j] }
    end
  end
end
