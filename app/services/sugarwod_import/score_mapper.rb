class SugarwodImport
  class ScoreMapper
    ROUNDS_PLUS_REPS_DISPLAY = /\A(\d+)\+(\d+)\z/

    def self.call(workout, row, user:) = new(workout, row, user: user).attributes

    def initialize(workout, row, user:)
      @workout = workout
      @row = row
      @user = user
    end

    def attributes
      { score_type: workout.score_type, score_value: score_value, notes: row[:notes].presence }
    end

    private

    attr_reader :workout, :row, :user

    def score_value
      case workout.score_type
      when 'time' then row[:best_result_raw].to_f.round
      when 'weight' then LoadEquivalence.to_lb(row[:best_result_raw].to_f, user.load_display_unit.to_s)
      when 'rep', 'round' then rep_or_round_value
      else row[:best_result_raw].to_i
      end
    end

    def rep_or_round_value
      return rounds_plus_reps_string if workout.rep_scored_amrap? && rounds_plus_reps_match

      row[:best_result_raw].to_i
    end

    def rounds_plus_reps_match
      row[:best_result_display].to_s.match(ROUNDS_PLUS_REPS_DISPLAY)
    end

    def rounds_plus_reps_string
      match = rounds_plus_reps_match
      "#{match[1]}+#{match[2]}"
    end
  end
end
