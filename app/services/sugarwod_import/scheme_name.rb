class SugarwodImport
  class SchemeName
    def self.call(movement, sets) = new(sets).name_for(movement)

    def initialize(sets)
      @sets = sets
    end

    def name_for(movement) = "#{movement.name} #{reps_label}"

    private

    attr_reader :sets

    # "7x2" reads far better than "2-2-2-2-2-2-2" when every set has the same reps -- the
    # dash-joined form is only worth its length when it's carrying real information, i.e. the
    # reps actually vary between sets (a pyramid scheme like "3-1-3-1-3-1-12"). A bare number
    # (e.g. "Power Clean 1") was ambiguous about what it meant, so even a single set uses "NxM"
    # ("Power Clean 1x1") for consistency with the multi-set case.
    def reps_label
      reps = sets.pluck(:reps)
      reps.uniq.one? ? "#{reps.size}x#{reps.first}" : reps.join('-')
    end
  end
end
