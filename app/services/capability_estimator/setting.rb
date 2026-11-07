class CapabilityEstimator
  # The load / distance a movement log was performed at, cleaned to what AthleteCapability accepts:
  # positive values only, and a distance only together with its unit. Logs routinely carry 0
  # placeholders (unprescribed reps, blank loads) and unitless distances, which would otherwise make
  # the whole recompute fail validation.
  module Setting
    def self.for(movement_log)
      distance = valid_distance?(movement_log)
      { load: positive(movement_log.load),
        distance: (movement_log.distance if distance),
        distance_unit: (movement_log.distance_unit if distance) }
    end

    def self.positive(value) = (value if value.to_i.positive?)

    def self.valid_distance?(movement_log)
      movement_log.distance.to_i.positive? && movement_log.distance_unit.present?
    end
  end
end
