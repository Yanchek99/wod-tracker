module CfWod
  class PreloadedState
    MARKER = 'window.__PRELOADED_STATE__='.freeze

    def self.parse(html) = new(html).parse

    def initialize(html)
      @html = html
    end

    def parse
      start = html.index(MARKER)
      return nil unless start

      JSON.parse(extract_balanced_json(html.index('{', start)))
    rescue JSON::ParserError
      nil
    end

    private

    attr_reader :html

    # Walks brace depth, skipping over characters inside JSON string literals so a quoted "{" or "}" isn't mistaken for structural nesting.
    def extract_balanced_json(start)
      depth = 0
      in_string = false
      escaped = false

      (start...html.length).each do |index|
        char = html[index]

        if in_string
          escaped, in_string = string_char_state(char, escaped)
        elsif char == '"'
          in_string = true
        elsif char == '{'
          depth += 1
        elsif char == '}'
          depth -= 1
          return html[start..index] if depth.zero?
        end
      end

      raise FetchError, 'Unterminated preloaded state JSON'
    end

    def string_char_state(char, escaped)
      return [false, true] if escaped
      return [false, false] if char == '"'

      [char == '\\', true]
    end
  end
end
