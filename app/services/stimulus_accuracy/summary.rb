class StimulusAccuracy
  # Plain-text lines summarizing a StimulusAccuracy::Report.
  module Summary
    module_function

    def lines(report)
      [
        "#{report.matched} claimed workout(s) matched, #{report.unmatched} not in this database",
        time_line(report.time), *window_lines(report), *loading_lines(report.loading), sets_line(report.sets),
        duration_line(report.duration), *miss_lines(report.worst)
      ]
    end

    def time_line(time)
      "Finish window overlaps CrossFit's: #{time[:overlap]} of #{time[:compared]} (median gap #{time[:median_gap] || 0} s)"
    end

    def window_lines(report)
      { 'Round time' => report.round, 'Target rounds' => report.rounds, 'Working-set %' => report.percent }
        .map { |label, window| "#{label} overlaps CrossFit's: #{window[:overlap]} of #{window[:compared]}" }
    end

    def loading_lines(matrix)
      matrix.map { |stated, row| "Loading stated #{stated}: #{row.map { |calc, n| "calculated #{calc} #{n}" }.join(', ')}" }
    end

    def sets_line(sets)
      "Sets guide: #{sets[:exact]} exact, #{sets[:within_one]} within one, of #{sets[:compared]}"
    end

    def duration_line(duration)
      "Time ceilings compared: #{duration[:compared]} (median gap #{duration[:median_gap_seconds] || 0} s)"
    end

    def miss_lines(worst)
      worst.map { |miss| "Miss: #{miss[:workout]} stated #{miss[:stated].inspect}, calculated #{miss[:calculated].inspect}" }
    end
  end
end
