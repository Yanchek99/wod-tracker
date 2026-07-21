module CfWod
  class PartSplitter
    IRRELEVANT_LINE_PATTERNS = [
      /\Ascroll for scaling options\.?\z/i,
      /\Apost .*to (?:the )?comments\.?\z/i,
      # Recurring rep-partitioning boilerplate (e.g. "Partition the pull-up and deadlift reps
      # any way." / "Partition the reps any way you like."): tells athletes how to split reps
      # already specified on the exercise lines, so it adds no exercise data of its own.
      /\Apartition (?:the |your )?(?:.+ )?reps any way(?:\s+you\s+\w+)?\.?\z/i
    ].freeze

    TIME_WINDOW = /\A(\d{1,2}:\d{2})-(\d{1,2}:\d{2}):\z/
    ROUNDS_OF = /\AThen,\s*(\d+)\s+rounds?\s+of(?:\s+the\s+couplet)?:\z/i
    BARE_THEN = /\AThen,\s*/i
    PRESCRIPTION_LINE = /\A(?:(?:men|women|male|female)\b|[♂♀])/i

    def self.call(body) = new(body).split

    def initialize(body)
      @all_lines = body.to_s.split("\n").map(&:strip).compact_blank
    end

    def split
      irrelevant, cleaned = all_lines.partition { |line| irrelevant_line?(line) }
      prescription = cleaned.reverse.take_while { |line| line.match?(PRESCRIPTION_LINE) }.reverse
      content = cleaned[0...(cleaned.length - prescription.length)]

      { parts: build_parts(content), prescription_text: prescription.join("\n").presence,
        notes: irrelevant.join("\n").presence }
    end

    private

    attr_reader :all_lines

    def irrelevant_line?(line)
      IRRELEVANT_LINE_PATTERNS.any? { |pattern| line.match?(pattern) }
    end

    def build_parts(content_lines)
      parts = [new_part]
      content_lines.each { |line| append_line(parts, line) }
      parts.reject { |part| part[:lines].empty? }
    end

    def append_line(parts, line)
      if (segment = segment_for(line))
        parts << segment
      elsif line.match?(BARE_THEN)
        parts << new_part
        parts.last[:lines] << line.sub(BARE_THEN, '')
      else
        parts.last[:lines] << line
      end
    end

    def segment_for(line)
      if (time_window_match = TIME_WINDOW.match(line))
        start_clock, end_clock = time_window_match.captures
        segment_part(name: "#{start_clock}-#{end_clock}", time_seconds: window_seconds(start_clock, end_clock))
      elsif (rounds_of_match = ROUNDS_OF.match(line))
        segment_part(rounds: rounds_of_match[1].to_i)
      end
    end

    def new_part
      { segment: false, name: nil, time_seconds: nil, rounds: nil, lines: [] }
    end

    def segment_part(name: nil, time_seconds: nil, rounds: nil)
      { segment: true, name: name, time_seconds: time_seconds, rounds: rounds, lines: [] }
    end

    def window_seconds(start_clock, end_clock)
      clock_time_to_seconds(end_clock) - clock_time_to_seconds(start_clock)
    end

    def clock_time_to_seconds(clock_time)
      minutes, seconds = clock_time.split(':').map(&:to_i)
      (minutes * 60) + seconds
    end
  end
end
