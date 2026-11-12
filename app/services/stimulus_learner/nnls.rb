module StimulusLearner
  # Non-negative least squares (Lawson-Hanson active-set method) in plain Ruby: minimizes
  # |A x - b| subject to x >= 0. Sized for the learner's small systems (tens of columns), so the
  # inner unconstrained solves use normal equations with Gaussian elimination. (The `matrix`
  # gem is only bundled for tests, so production can't lean on it.)
  module Nnls
    TOLERANCE = 1e-10
    MAX_ITERATIONS = 500

    module_function

    def solve(rows, targets)
      solution = Array.new(rows.first&.size.to_i, 0.0)
      passive = []
      MAX_ITERATIONS.times do
        candidate = next_column(rows, targets, solution, passive)
        break unless candidate

        passive << candidate
        solution = refine(rows, targets, solution, passive)
      end
      solution
    end

    # The inactive column whose gradient most wants to grow, or nil once none does.
    def next_column(rows, targets, solution, passive)
      gradient = gradient(rows, targets, solution)
      candidate = solution.each_index.reject { |j| passive.include?(j) }.max_by { |j| gradient[j] }
      candidate if candidate && gradient[candidate] > TOLERANCE
    end

    # Solve on the passive set; while the unconstrained answer goes negative, step back toward
    # feasibility and drop the columns that reach zero.
    def refine(rows, targets, solution, passive)
      loop do
        trial = least_squares(rows, targets, passive, solution.size)
        return trial if passive.all? { |j| trial[j] > TOLERANCE }

        solution = step_toward(solution, trial, passive)
        passive.reject! { |j| solution[j] <= TOLERANCE }
        return solution if passive.empty?
      end
    end

    def step_toward(solution, trial, passive)
      blocked = passive.select { |j| trial[j] <= TOLERANCE }
      step = blocked.map { |j| solution[j] / (solution[j] - trial[j]) }.min
      solution.each_index.map { |j| solution[j] + (step * (trial[j] - solution[j])) }
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
      passive.map { |a| passive.map { |b| rows.sum { |row| row[a] * row[b] } } }
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
      return if pivot_row[col].abs < TOLERANCE

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
        next if augmented[r][r].abs < TOLERANCE

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
