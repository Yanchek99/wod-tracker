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
    PENALTY_TRIGGER_PATTERN = /\A(?:any|every) time (?:you|the athlete) stops?\b/i
    REST_PATTERN = /\Arest\s+(?<minutes>\d+)\s*minutes?/i
    META_PATTERNS = [
      /\Apost\b.*\bto comments\.?\z/i,
      /\Ayour score is\b/i,
      /\Ascroll for scaling options\.?\z/i,
      /\Acompare to \d+\.?\z/i
    ].freeze
    SCALED_LOAD_LINE_PATTERNS = [/[♀♂]/, /\A(?:men|women):/i].freeze

    def initialize(body_text)
      @body_text = body_text
    end

    def paragraphs
      body_text.split(/\n{2,}/).map(&:strip).reject(&:empty?)
    end

    CLASSIFICATION_RULES = [
      [:segment_header, ->(line) { line.match?(CLOCK_WINDOW_PATTERN) }],
      [:penalty_trigger, ->(line) { line.match?(PENALTY_TRIGGER_PATTERN) }],
      [:header, ->(line) { HEADER_PATTERNS.any? { |pattern| line.match?(pattern) } }],
      [:rest, ->(line) { line.match?(REST_PATTERN) }],
      [:meta, ->(line) { META_PATTERNS.any? { |pattern| line.match?(pattern) } }],
      [:scaled_load, ->(line) { SCALED_LOAD_LINE_PATTERNS.any? { |pattern| line.match?(pattern) } }]
    ].freeze

    def classify(line)
      match = CLASSIFICATION_RULES.find { |_kind, matcher| matcher.call(line) }
      match ? match.first : :movement
    end

    def segment_header_minutes(line)
      CLOCK_WINDOW_PATTERN.match(line)&.[](:minutes)&.to_i
    end

    def rest_minutes(line)
      REST_PATTERN.match(line)&.[](:minutes)&.to_i
    end

    private

    attr_reader :body_text
  end
end
