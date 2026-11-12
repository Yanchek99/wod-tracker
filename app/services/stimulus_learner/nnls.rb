module StimulusLearner
  # Non-negative least squares (Lawson-Hanson active-set method) in plain Ruby: minimizes
  # |A x - b| subject to x >= 0. Sized for the learner's small systems (tens of columns), so the
  # inner unconstrained solves use normal equations (see LinearSystem). (The `matrix` gem is only
  # bundled for tests, so production can't lean on it.)
  #
  # Every loop is bounded: the outer loop by MAX_ITERATIONS, the inner one because each pass
  # drops at least one column from the passive set. A column that falls straight back out right
  # after joining is not retried, which stops add/drop cycling on degenerate systems.
  class Nnls
    MAX_ITERATIONS = 500
    # Relative ridge added to the normal equations' diagonal so duplicate or collinear columns
    # stay solvable instead of producing a singular system.
    RIDGE = 1e-9

    def self.solve(rows, targets) = new(rows, targets).solve

    def initialize(rows, targets)
      @rows = rows
      @targets = targets
      @tolerance = tolerance
      @solution = Array.new(rows.first&.size.to_i, 0.0)
      @passive = []
      @rejected = []
    end

    def solve
      MAX_ITERATIONS.times do
        candidate = next_column
        break unless candidate

        add_column(candidate)
      end
      @solution.map { |value| value.finite? && value > @tolerance ? value : 0.0 }
    end

    private

    # Brings a column into the passive set and re-solves.
    def add_column(candidate)
      @passive << candidate
      refine
      @rejected << candidate unless @passive.include?(candidate)
    end

    # Scale-aware zero: the data's magnitude decides what counts as zero.
    def tolerance
      scale = [@rows.flatten.map(&:abs).max.to_f, @targets.map(&:abs).max.to_f, 1.0].max
      scale * @rows.size * 1e-12
    end

    # The inactive column whose gradient most wants to grow, or nil once none does.
    def next_column
      gradient = gradient()
      excluded = @passive + @rejected
      candidate = @solution.each_index.reject { |j| excluded.include?(j) }.max_by { |j| gradient[j] }
      candidate if candidate && gradient[candidate] > @tolerance
    end

    # Solve on the passive set; while the unconstrained answer is not positive, step back toward
    # feasibility, zero the blocking column(s) and drop them.
    def refine
      @passive.size.times do
        trial = least_squares
        return @solution = trial if @passive.all? { |j| trial[j] > @tolerance }

        step_toward(trial)
        @passive.reject! { |j| @solution[j] <= @tolerance }
        return if @passive.empty?
      end
    end

    # Moves from the solution toward trial as far as feasibility allows, and zeroes every passive
    # column that is non-positive at that point (always at least the blocking one).
    def step_toward(trial)
      blocked = @passive.select { |j| trial[j] <= @tolerance }
      step = feasible_step(trial, blocked)
      moved = @solution.each_index.map { |j| @solution[j] + ((step || 0.0) * (trial[j] - @solution[j])) }
      blocked.each { |j| moved[j] = 0.0 if step.nil? || moved[j] <= @tolerance }
      @solution = moved
    end

    # The largest step that keeps every blocked column non-negative; nil when no blocked column
    # can move (e.g. a column already at zero whose trial value is also zero).
    def feasible_step(trial, blocked)
      blocked.filter_map do |j|
        denominator = @solution[j] - trial[j]
        @solution[j] / denominator if denominator > @tolerance
      end.min
    end

    def gradient
      residuals = @rows.each_with_index.map { |row, i| @targets[i] - dot(row) }
      @solution.each_index.map { |j| @rows.each_with_index.sum { |row, i| row[j] * residuals[i] } }
    end

    def least_squares
      values = LinearSystem.solve(normal_matrix, normal_rhs)
      Array.new(@solution.size, 0.0).tap { |full| @passive.each_with_index { |j, k| full[j] = values[k] } }
    end

    def normal_matrix
      matrix = @passive.map { |a| @passive.map { |b| @rows.sum { |row| row[a] * row[b] } } }
      ridge = RIDGE * [matrix.each_with_index.map { |row, i| row[i] }.max.to_f, 1.0].max
      matrix.each_with_index { |row, i| row[i] += ridge }
    end

    def normal_rhs
      @passive.map { |a| @rows.each_with_index.sum { |row, i| row[a] * @targets[i] } }
    end

    def dot(row)
      row.each_with_index.sum { |value, j| value * @solution[j] }
    end
  end
end
