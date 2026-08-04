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
    # reps actually vary between sets (a pyramid scheme like "3-1-3-1-3-1-12"). A single set
    # just states its own rep count with no "1x" prefix, since there's nothing to multiply.
    def reps_label
      reps = sets.pluck(:reps)
      return reps.first.to_s if reps.one?
      return "#{reps.size}x#{reps.first}" if reps.uniq.one?

      reps.join('-')
    end
  end
end
