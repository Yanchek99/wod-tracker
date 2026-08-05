class SugarwodImport
  class ScoreMapper
    ROUNDS_PLUS_REPS_DISPLAY = /\A(\d+)\+(\d+)\z/

    def self.call(workout, row, user:) = new(workout, row, user: user).attributes

    def initialize(workout, row, user:)
      @workout = workout
      @row = row
      @user = user
    end

    # nil when best_result_raw isn't a valid value for the workout's score type (e.g. SugarWOD
    # text like "not recorded" for a numeric score) -- to_f/to_i would silently coerce that
    # garbage to 0, fabricating a bogus recorded result, so the caller must check for nil and
    # skip the row instead of importing it.
    def attributes
      value = score_value
      return unless value

      { score_type: workout.score_type, score_value: value, notes: row[:notes].presence }
    end

    private

    attr_reader :workout, :row, :user

    def score_value
      case workout.score_type
      when 'time' then parsed_float&.round
      when 'weight' then parsed_weight
      when 'rep', 'round' then rep_or_round_value
      else parsed_integer
      end
    end

    def parsed_weight
      raw = parsed_float
      LoadEquivalence.to_lb(raw, user.load_display_unit.to_s) if raw
    end

    def rep_or_round_value
      return rounds_plus_reps_string if workout.rep_scored_amrap? && rounds_plus_reps_match

      parsed_integer
    end

    def parsed_float
      Float(row[:best_result_raw], exception: false)
    end

    def parsed_integer
      Integer(row[:best_result_raw], exception: false)
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
