module CfWod
  class FormatDetector
    Result = Data.define(:score_type, :time, :rounds, :interval, :time_cap_seconds)

    INTERVAL_PATTERN = /\b(\d+(?:-\d+){2,})\b/
    AMRAP_PATTERNS = [
      /as many (?:rounds|reps) as possible in\s*(\d+)\s*minutes?/i,
      /complete as many rounds as possible in\s*(\d+)\s*minutes?/i,
      /(\d+)[\s-]minutes?\s+AMRAP/i,
      /AMRAP\s+(?:in\s+)?(\d+)\s*minutes?/i
    ].freeze
    ROUND_SCORED_CUE = /post\s+(?:total\s+)?rounds?(?:\s+completed)?|note\s+(?:the\s+)?number\s+of\b.*\bfor each round/i
    EMOM_SINGLE_MINUTE_PATTERN = /every minute on the minute for\s*(\d+)\s*minutes?/i
    EMOM_INTERVAL_PATTERN = /every\s*(\d+)\s*minutes?,?\s*for\s*(\d+)\s*minutes?/i
    LIFTING_PATTERNS = [
      /\b1[\s-]?rep[\s-]?max\b/i,
      /find a\b.*\bmax\b/i,
      /establish a\b.*\bmax\b/i,
      /build to a heavy\b/i
    ].freeze
    TIME_CAP_PATTERNS = [
      /(\d+)[\s-]minute time cap/i,
      /within\s*(\d+)\s*minutes?/i
    ].freeze
    FOR_TIME_PATTERN = /\bfor time\b/i
    ROUNDS_FOR_TIME_PATTERN = /(\d+)\s*rounds?,?\s*each\s*for time/i

    def initialize(body_text)
      @body_text = body_text
    end

    def detect
      interval_result || amrap_result || emom_result || lifting_result || for_time_result || no_match_result
    end

    private

    attr_reader :body_text

    def blank_result
      Result.new(score_type: nil, time: nil, rounds: nil, interval: nil, time_cap_seconds: nil)
    end

    def no_match_result
      blank_result
    end

    # 3+ dash-joined numbers. Descending ("21-15-9") is a rep ladder, for-time. All-equal ("5-5-5")
    # is a set-based lifting scheme, weight-scored, matching Workout#set_based_lifting?'s expectation
    # of rounds present with no time/interval.
    def interval_result
      match = INTERVAL_PATTERN.match(body_text)
      return unless match

      numbers = match[1].split('-').map(&:to_i)
      if numbers.each_cons(2).all? { |a, b| a > b }
        blank_result.with(score_type: :time, interval: match[1])
      elsif numbers.uniq.one?
        blank_result.with(score_type: :weight, rounds: numbers.size)
      end
    end

    def amrap_result
      minutes = AMRAP_PATTERNS.filter_map { |pattern| body_text[pattern, 1] }.first
      return unless minutes

      score_type = body_text.match?(ROUND_SCORED_CUE) ? :round : :rep
      blank_result.with(score_type: score_type, time: minutes.to_i)
    end

    def emom_result
      if (match = EMOM_SINGLE_MINUTE_PATTERN.match(body_text))
        total = match[1].to_i
        blank_result.with(score_type: :rep, time: total, rounds: total)
      elsif (match = EMOM_INTERVAL_PATTERN.match(body_text))
        interval_minutes, total = match.captures.map(&:to_i)
        blank_result.with(score_type: :rep, time: total, rounds: total / interval_minutes)
      end
    end

    def lifting_result
      return unless LIFTING_PATTERNS.any? { |pattern| body_text.match?(pattern) }

      seconds = TIME_CAP_PATTERNS.filter_map { |pattern| body_text[pattern, 1] }.first
      blank_result.with(score_type: :weight, time_cap_seconds: seconds&.to_i&.*(60))
    end

    def for_time_result
      first_line = body_text.lines.first.to_s
      return unless first_line.match?(FOR_TIME_PATTERN)

      rounds = body_text[ROUNDS_FOR_TIME_PATTERN, 1]
      blank_result.with(score_type: :time, rounds: rounds&.to_i)
    end
  end
end
