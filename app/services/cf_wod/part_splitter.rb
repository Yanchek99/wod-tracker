module CfWod
  class PartSplitter
    BOILERPLATE_LINE_PATTERNS = [
      /\Ascroll for scaling options\.?\z/i,
      /\Apost .*to comments\.?\z/i
    ].freeze

    TIME_WINDOW = /\A(\d{1,2}:\d{2})-(\d{1,2}:\d{2}):\z/
    ROUNDS_OF = /\AThen,\s*(\d+)\s+rounds?\s+of(?:\s+the\s+couplet)?:\z/i
    BARE_THEN = /\AThen,\s*/i
    PRESCRIPTION_LINE = /\A(?:men|women|male|female|♂|♀)\b/i

    def self.call(body) = new(body).split

    def initialize(body)
      @all_lines = body.to_s.split("\n").map(&:strip).compact_blank
    end

    def split
      cleaned = all_lines.reject { |line| boilerplate_line?(line) }
      prescription = cleaned.reverse.take_while { |line| line.match?(PRESCRIPTION_LINE) }.reverse
      content = cleaned[0...(cleaned.length - prescription.length)]

      { parts: build_parts(content), prescription_text: prescription.join("\n").presence }
    end

    private

    attr_reader :all_lines

    def boilerplate_line?(line)
      BOILERPLATE_LINE_PATTERNS.any? { |pattern| line.match?(pattern) }
    end

    def build_parts(content_lines)
      parts = [new_part]

      content_lines.each do |line|
        if (match = TIME_WINDOW.match(line))
          parts << segment_part(name: "#{match[1]}-#{match[2]}", time_seconds: window_seconds(match))
        elsif (match = ROUNDS_OF.match(line))
          parts << segment_part(rounds: match[1].to_i)
        elsif line.match?(BARE_THEN)
          parts << new_part
          parts.last[:lines] << line.sub(BARE_THEN, '')
        else
          parts.last[:lines] << line
        end
      end

      parts.reject { |part| part[:lines].empty? }
    end

    def new_part
      { segment: false, name: nil, time_seconds: nil, rounds: nil, lines: [] }
    end

    def segment_part(name: nil, time_seconds: nil, rounds: nil)
      { segment: true, name: name, time_seconds: time_seconds, rounds: rounds, lines: [] }
    end

    def window_seconds(match)
      to_seconds(match[2]) - to_seconds(match[1])
    end

    def to_seconds(clock)
      minutes, seconds = clock.split(':').map(&:to_i)
      (minutes * 60) + seconds
    end
  end
end
