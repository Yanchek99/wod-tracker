# Normalizes a prescribed travel distance to the canonical magnitude in meters. Meter is the
# canonical unit; mile and kilometer are display conventions for the same prescription
# (see cf/docs/load-and-distance-equivalence.md).
#
# Scope: travel distances only. `foot`/`inch` distances and all height cases (target height, box
# height) are intentionally out of scope and left in their own units, so this module does not
# convert them.
module DistanceEquivalence
  INPUT_UNITS = %w[meter km mile].freeze

  METERS_PER_KM = 1000
  MILE_METERS = 1600 # CrossFit's published mile convention (e.g. Murph), not the exact 1609.344

  module_function

  # Canonical distance in meters (integer), or nil when no value is given.
  def to_meters(value, unit)
    return if value.nil?

    case unit.to_s
    when '', 'meter' then value.round
    when 'km' then (value * METERS_PER_KM).round
    when 'mile' then value * MILE_METERS
    else raise ArgumentError, "unknown travel-distance unit: #{unit.inspect}"
    end
  end
end
