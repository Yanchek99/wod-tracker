module CfWod
  class LineParser
    Result = Data.define(:reps, :calories, :distance, :distance_unit, :movement_name, :notes)

    LEADING_QUANTITY = /\A(?<reps>\d+|max)[\s,-]+(?:reps?\s+)?(?<rest>.+)\z/i
    CALORIE_CLOCK_PHRASE = /\Amax-calorie\s+(?<movement>.+?)\s+in the remaining time\z/i
    CALORIE_LEAD_VERB = /\A(?<movement>row|run|bike|swim)\s+for\s+(?:max\s+)?calories?\z/i
    CALORIE_PREFIX = /\A(?<calories>\d+)-?calorie\s+(?<rest>.+)\z/i
    DISTANCE_LEAD = /\A(?<value>[\d,]+)[\s-](?:meter|foot|ft|feet|m|inch|in)s?\.?\s+(?<rest>.+)\z/i
    DISTANCE_UNIT_IN_LEAD = /\A[\d,]+[\s-](?<unit>meter|foot|ft|feet|m|inch|in)s?\b/i
    TRAILING_CLAUSE = /,\s*.*\z|\s+(?:with|while|carrying)\b.*\z/i
    # A non-scaled-load trailing annotation, e.g. "(each)"/"(total)"/"(together)" on partner/team lines.
    # Digit-bearing parentheticals (loads/distances) are already stripped by ExerciseLoadAttacher
    # before a line reaches here, so anything left is descriptive, not a prescription.
    TRAILING_ANNOTATION = /\s*\(([^)]+)\)\z/

    def self.parse(line) = new(line).parse

    def initialize(line)
      @line = line.strip
    end

    def parse
      calorie_clock_result || calorie_verb_result || distance_led_result || leading_quantity_result || bare_movement_result
    end

    private

    attr_reader :line

    def calorie_clock_result
      match = CALORIE_CLOCK_PHRASE.match(line)
      return unless match

      finalize(calories: 0, movement_name: match[:movement])
    end

    def calorie_verb_result
      match = CALORIE_LEAD_VERB.match(line)
      return unless match

      finalize(calories: 0, movement_name: match[:movement])
    end

    def distance_led_result
      match = DISTANCE_LEAD.match(line)
      return unless match

      unit = DISTANCE_UNIT_IN_LEAD.match(line)[:unit]
      finalize(distance: match[:value].delete(',').to_i, distance_unit: normalize_distance_unit(unit), movement_name: match[:rest])
    end

    def leading_quantity_result
      match = LEADING_QUANTITY.match(line)
      return unless match

      reps = match[:reps].match?(/\Amax\z/i) ? 0 : match[:reps].to_i
      calorie_match = CALORIE_PREFIX.match(match[:rest])
      if calorie_match
        finalize(reps: reps, calories: calorie_match[:calories].to_i, movement_name: calorie_match[:rest])
      else
        finalize(reps: reps, movement_name: match[:rest])
      end
    end

    def bare_movement_result
      finalize(movement_name: line)
    end

    def finalize(movement_name:, reps: nil, calories: nil, distance: nil, distance_unit: nil)
      cleaned, clause_notes = strip_trailing_clause(movement_name)
      cleaned, annotation_notes = strip_trailing_annotation(cleaned)
      notes = [clause_notes, annotation_notes].compact.join('; ').presence
      Result.new(reps: reps, calories: calories, distance: distance, distance_unit: distance_unit,
                 movement_name: cleaned, notes: notes)
    end

    def strip_trailing_clause(text)
      match = TRAILING_CLAUSE.match(text)
      return [text.strip, nil] unless match

      [text[0...match.begin(0)].strip, match[0].sub(/\A,?\s+/, '').strip.presence]
    end

    def strip_trailing_annotation(text)
      match = TRAILING_ANNOTATION.match(text)
      return [text, nil] unless match

      [text[0...match.begin(0)].strip, match[1].strip]
    end

    def normalize_distance_unit(unit)
      case unit.downcase
      when 'ft', 'feet', 'foot' then 'foot'
      when 'in', 'inch' then 'inch'
      else 'meter'
      end
    end
  end
end
