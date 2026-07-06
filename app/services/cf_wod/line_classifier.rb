module CfWod
  class LineClassifier
    HEADER_PATTERNS = [
      /:\s*\z/,
      /\bas many (?:rounds|reps) as possible in\s*\d+\s*minutes?\s+of\b/i,
      /\bevery minute on the minute for\s*\d+\s*minutes?\z/i,
      /\b\d+(?:-\d+){2,}\s+reps?\s+for time\s+of\b/i,
      /\bestablish a\b.*\bmax\b/i,
      /\bfind a\b.*\bmax\b/i,
      /\b1[\s-]?rep[\s-]?max\b/i,
      /\bbuild to a heavy\b/i
    ].freeze
    CLOCK_WINDOW_PATTERN = /\Aon an?\s*(?<minutes>\d+)[\s-]?minutes?\s+clock:?\z/i
    # Window headers like "0:00-5:00:" are elapsed MM:SS on the workout's running clock, not H:MM.
    TIME_RANGE_HEADER_PATTERN =
      /\A(?<start_min>\d+):(?<start_sec>\d{2})-(?<end_min>\d+):(?<end_sec>\d{2}):?\z/
    PENALTY_TRIGGER_PATTERN = /\A(?:any|every) time (?:you|the athlete) stops?\b/i
    REST_PATTERN = /\Arest\s+(?<minutes>\d+)\s*minutes?/i
    META_PATTERNS = [
      /\Apost\b.*\bto comments\.?\z/i,
      /\Ayour score is\b/i,
      /\Ascroll for scaling options\.?\z/i,
      /\Acompare to \d+\.?\z/i
    ].freeze
    GENDERED_LOAD_LINE_PATTERNS = [/[♀♂]/, /\A(?:men|women):/i].freeze

    CLASSIFICATION_RULES = [
      [:segment_header, ->(line) { [CLOCK_WINDOW_PATTERN, TIME_RANGE_HEADER_PATTERN].any? { |pattern| line.match?(pattern) } }],
      [:penalty_trigger, ->(line) { [PENALTY_TRIGGER_PATTERN].any? { |pattern| line.match?(pattern) } }],
      [:header, ->(line) { HEADER_PATTERNS.any? { |pattern| line.match?(pattern) } }],
      [:rest, ->(line) { [REST_PATTERN].any? { |pattern| line.match?(pattern) } }],
      [:meta, ->(line) { META_PATTERNS.any? { |pattern| line.match?(pattern) } }],
      [:gendered_load, ->(line) { GENDERED_LOAD_LINE_PATTERNS.any? { |pattern| line.match?(pattern) } }]
    ].freeze

    def initialize(body_text)
      @body_text = body_text
    end

    def classify(line)
      match = CLASSIFICATION_RULES.find { |_kind, matcher| matcher.call(line) }
      match ? match.first : :movement
    end

    def segment_header_minutes(line)
      clock_window_minutes(line) || time_range_minutes(line)
    end

    def rest_minutes(line)
      REST_PATTERN.match(line)&.[](:minutes)&.to_i
    end

    def paragraphs
      body_text.split(/\n{2,}/).map(&:strip).reject(&:empty?)
    end

    private

    attr_reader :body_text

    def clock_window_minutes(line)
      CLOCK_WINDOW_PATTERN.match(line)&.[](:minutes)&.to_i
    end

    def time_range_minutes(line)
      match = TIME_RANGE_HEADER_PATTERN.match(line)
      return unless match

      start_total_seconds = (match[:start_min].to_i * 60) + match[:start_sec].to_i
      end_total_seconds = (match[:end_min].to_i * 60) + match[:end_sec].to_i
      (end_total_seconds - start_total_seconds).fdiv(60).round
    end
  end
end
