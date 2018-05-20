class Measurement < ApplicationRecord
  UNITS = { weight: 'lb', distance: 'meter', time: 'minute', height: 'inch' }.freeze

  def unit
    return UNITS.fetch(name.to_sym) if UNITS.key?(name.to_sym)
    name
  end

  def rep?
    name.eql? 'rep'
  end

  def round?
    name.eql? 'round'
  end
end
