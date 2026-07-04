module CfWod
  class ScaledLoadParser
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

      build_result(female, male)
    end

    def labeled_result
      male = LABELED_MALE.match(text)
      female = LABELED_FEMALE.match(text)
      return unless male || female

      build_result(female, male)
    end

    def slash_result
      match = SLASH_PATTERN.match(text)
      return unless match

      Result.new(
        female_value: value_of(match[:female]),
        male_value: value_of(match[:male]),
        unit: normalize_unit(match[:unit]),
        dimension: dimension_for(match[:unit])
      )
    end

    def build_result(female_match, male_match)
      unit = (female_match || male_match)[:unit]
      Result.new(
        female_value: value_of(female_match&.[](:value)),
        male_value: value_of(male_match&.[](:value)),
        unit: normalize_unit(unit),
        dimension: dimension_for(unit)
      )
    end

    def value_of(raw)
      raw&.delete(',')&.to_i
    end

    def normalize_unit(unit)
      case unit.downcase
      when 'ft' then 'foot'
      when 'in' then 'inch'
      else unit.downcase
      end
    end

    def dimension_for(unit)
      %w[lb kg].include?(unit.downcase) ? :load : :distance
    end
  end
end
