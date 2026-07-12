module CfWorkout
  class PrescriptionClauseParser
    MALE_PREFIX = /\A(?:men|male|♂):?\s*/i
    FEMALE_PREFIX = /\A(?:women|female|♀):?\s*/i
    CLAUSE_PATTERN = /\A([\d,]+(?:\.\d+)?)[\s-](lb|kg|pood|inch|foot|in|ft)\.?\s*(.*?)\.?\z/i
    TARGET_SUFFIX = /\s+to\s+a\s+([\d,]+)-(foot|ft|inch|in)\.?\s+(.+)\z/i
    UNIT_ALIASES = { 'lb' => :lb, 'kg' => :kg, 'pood' => :pood, 'inch' => :inch, 'in' => :inch,
                     'foot' => :foot, 'ft' => :foot }.freeze

    def self.call(text) = new(text).parse

    def initialize(text)
      @lines = text.to_s.split("\n").map(&:strip).compact_blank
    end

    def parse
      { female: clauses_for(FEMALE_PREFIX), male: clauses_for(MALE_PREFIX) }
    end

    private

    attr_reader :lines

    def clauses_for(prefix_pattern)
      line = lines.find { |candidate| candidate.match?(prefix_pattern) }
      return [] unless line

      line.sub(prefix_pattern, '').split(/,\s*(?:and\s+)?/i).filter_map { |clause| parse_clause(clause.strip) }
    end

    def parse_clause(clause)
      target_match = clause.match(TARGET_SUFFIX)
      base = target_match ? clause.sub(target_match[0], '').strip : clause
      base_match = base.match(CLAUSE_PATTERN)
      return nil unless base_match

      values = [clause_value(base_match[1], base_match[2], base_match[3])]
      values << clause_value(target_match[1], target_match[2], target_match[3]) if target_match
      values
    end

    def clause_value(raw_value, raw_unit, implement)
      { value: numeric_value(raw_value), unit: UNIT_ALIASES.fetch(raw_unit.downcase), implement: implement.strip }
    end

    # Preserves decimal precision (e.g. "22.5" kg): LoadEquivalence's published kg -> lb table keys
    # on the exact decimal magnitude, so truncating to an integer here would miss lookups like
    # KG_TO_LB[22.5] and fall back to an imprecise generic conversion instead.
    def numeric_value(raw_value)
      cleaned = raw_value.delete(',')
      cleaned.include?('.') ? cleaned.to_f : cleaned.to_i
    end
  end
end
