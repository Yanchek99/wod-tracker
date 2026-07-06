module CfWod
  module InlineLoadExtractor
    CLAUSE = /\(([^)]*\d[^)]*)\)/

    def self.extract(line)
      match = CLAUSE.match(line)
      return [line, nil] unless match

      result = GenderedLoadParser.parse(match[0])
      return [line, nil] unless result

      [line.sub(match[0], '').strip, result]
    end
  end
end
