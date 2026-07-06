# Normalizes a prescribed load expressed in any CrossFit unit (lb, kg, or pood) to the canonical
# magnitude in pounds. lb is CrossFit's official unit; kg and pood are display conventions for the
# same prescription, so identity must not depend on which one was entered or imported
# (see cf/docs/load-and-distance-equivalence.md and cf/docs/decisions.md).
module LoadEquivalence
  INPUT_UNITS = %w[lb kg pood].freeze

  # Source-confirmed kg -> lb pairs (CrossFit Open, games.crossfit.com) plus the standard
  # kettlebell implements. Several kg labels may map to one canonical lb value because the published
  # kg rounding varies by year (e.g. 65 lb was labelled 29 and 29.5 kg).
  KG_TO_LB = {
    15 => 35, 22.5 => 50, 29 => 65, 29.5 => 65, 34 => 75, 38.5 => 85,
    43 => 95, 61 => 135, 83 => 185, 102 => 225, 124 => 275, 142 => 315,
    16 => 35, 24 => 53, 32 => 70 # standard kettlebells (1 / 1.5 / 2 pood)
  }.freeze

  # Standard kettlebell implements, by pood.
  POOD_TO_LB = { 1 => 35, 1.5 => 53, 2 => 70 }.freeze

  KG_PER_POOD = 16
  LB_PER_KG = 2.20462

  module_function

  # Canonical load in pounds (integer), or nil when no value is given.
  def to_lb(value, unit)
    return if value.nil?

    case unit.to_s
    when '', 'lb' then value.round
    when 'kg' then kg_to_lb(value)
    when 'pood' then POOD_TO_LB[value] || kg_to_lb(value * KG_PER_POOD)
    else raise ArgumentError, "unknown load unit: #{unit.inspect}"
    end
  end

  # kg label for displaying a canonical lb load to a metric athlete, using the source-confirmed
  # pairs where available and a rounded conversion otherwise.
  def lb_to_kg(pounds)
    return if pounds.nil?

    KG_TO_LB.key(pounds) || (pounds / LB_PER_KG).round
  end

  def kg_to_lb(kilograms)
    KG_TO_LB[kilograms] || (((kilograms * LB_PER_KG) / 5).round * 5) # documented fallback: nearest 5 lb
  end
end
