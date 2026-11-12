module StimulusLearner
  # Solves a small square linear system by Gaussian elimination with partial pivoting. A
  # (near-)singular pivot leaves that unknown at zero rather than dividing by it.
  module LinearSystem
    module_function

    def solve(matrix, rhs)
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
  end
end
