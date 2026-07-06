module CfWod
  class GenderedLoadParser
    Result = Data.define(:female_value, :male_value, :unit, :dimension)

    SYMBOL_FEMALE = /♀\s*(?<value>[\d,]+)[\s-]?(?<unit>lb|kg|in|ft)\b/i
    SYMBOL_MALE = /♂\s*(?<value>[\d,]+)[\s-]?(?<unit>lb|kg|in|ft)\b/i
    LABELED_MALE = /\bMen:\s*(?<value>[\d,]+)\s*(?<unit>lb|kg)\b/i
    LABELED_FEMALE = /\bWomen:\s*(?<value>[\d,]+)\s*(?<unit>lb|kg)\b/i
    # Real seed prose confirms male/female order, e.g. "(75 / 55 lb)" -> female_load: 55, male_load: 75.
    SLASH_PATTERN = %r{\((?<male>[\d,]+)\s*/\s*(?<female>[\d,]+)\s*(?<unit>lb|kg)\b}i

    def self.parse(text) = new(text).parse

    def initialize(text)
      @text = text
    end

    def parse
      symbol_result || labeled_result || slash_result
    end

    private

    attr_reader :text

    def symbol_result
      female = SYMBOL_FEMALE.match(text)
      male = SYMBOL_MALE.match(text)
      return unless female || male

      result_for(female&.[](:value), male&.[](:value), (female || male)[:unit])
    end

    def labeled_result
      male = LABELED_MALE.match(text)
      female = LABELED_FEMALE.match(text)
      return unless male || female

      result_for(female&.[](:value), male&.[](:value), (female || male)[:unit])
    end

    def slash_result
      match = SLASH_PATTERN.match(text)
      return unless match

      result_for(match[:female], match[:male], match[:unit])
    end

    def result_for(female_value, male_value, unit)
      Result.new(female_value: value_of(female_value), male_value: value_of(male_value),
                 unit: normalize_unit(unit), dimension: dimension_for(unit))
    end

    def value_of(raw)
      raw&.delete(',')&.to_i
    end

    def normalize_unit(unit) = UnitNormalizer.normalize(unit)

    def dimension_for(unit)
      %w[lb kg].include?(unit.downcase) ? :load : :distance
    end
  end
end
