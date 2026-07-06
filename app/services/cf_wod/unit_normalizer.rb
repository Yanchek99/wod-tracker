module CfWod
  module UnitNormalizer
    def self.normalize(unit)
      case unit.downcase
      when 'ft', 'feet', 'foot' then 'foot'
      when 'in', 'inch' then 'inch'
      when 'm', 'meter', 'meters' then 'meter'
      else unit.downcase
      end
    end
  end
end
