class SugarwodImport
  class UntaggedBarbellLiftDetector
    def self.call(row) = new(row).build

    def initialize(row)
      @row = row
    end

    def build
      return nil if row[:barbell_lift].present?

      movement = candidate_movement
      return nil unless movement

      sets = SetSchemeExtractor.call(row)
      return nil unless sets

      build_workout(movement, sets)
    end

    private

    attr_reader :row

    # Title and description are peers, not title-primary: some rows have an unambiguous single
    # movement named only in the description (a generic title like "Skill Work"), while others
    # have a bare movement name as the title with a purely numeric description ("Back Squat" |
    # "5 Sets of 5") that never restates the movement in free text. 2+ movements named in the
    # description always means "reject" -- that's what catches a real complex hiding behind a
    # single-movement-sounding title (e.g. "Clean Pulls" whose description is actually Clean
    # Deadlift + Hang Clean Pull, three named variants in one set).
    def candidate_movement
      case described_movements.size
      when 0 then title_movement
      when 1 then described_movements.first unless conflicting_title?
      end
    end

    def conflicting_title?
      title_movement && title_movement != described_movements.first
    end

    def title_movement
      movement = CfWod::MovementLookup.call(row[:title])
      movement if movement&.family_weightlifting?
    end

    def described_movements
      @described_movements ||= weightlifting_names.each_with_object([]) do |name, found|
        pattern = movement_name_pattern(name)
        next unless remaining_description.match?(pattern)

        found << CfWod::MovementLookup.call(name)
        @remaining_description = @remaining_description.gsub(pattern, '')
      end.compact
    end

    # SugarWOD descriptions almost always pluralize the movement ("3 power snatches", "5
    # Front Squats"), but a plain \b...\b word-boundary regex never matches a plural: \b
    # requires a transition between a word char and a non-word char, and there is none
    # between a singular name's last letter and an attached "s"/"es". Matching either the
    # singular or the (regularly) pluralized form keeps the boundary discipline that stops
    # "Clean" matching inside "Cleaner"-style false positives.
    def movement_name_pattern(name)
      /\b(?:#{Regexp.escape(name.pluralize)}|#{Regexp.escape(name)})\b/i
    end

    # Normalizing "&" to "and" up front (mirroring CfWod::MovementLookup's own normalization)
    # matters for correctness, not just coverage: without it, "Clean & Jerk" fails to match the
    # catalog's "Clean and Jerk" pattern, but its own substring "Clean" still matches on its own --
    # silently misidentifying a Clean and Jerk row as a bare Clean.
    def remaining_description
      @remaining_description ||= row[:description].to_s.gsub(/\s*&\s*/, ' and ')
    end

    def weightlifting_names
      Movement.where(family: :weightlifting).order(Arel.sql('LENGTH(name) DESC')).pluck(:name)
    end

    def build_workout(movement, sets)
      workout = Workout.new(score_type: :weight, name: SchemeName.call(movement, sets))
      segment = workout.segments.build(position: 1)
      sets.each_with_index do |set, index|
        segment.exercises.build(movement: movement, position: index + 1, reps: set[:reps])
      end
      workout
    end
  end
end
