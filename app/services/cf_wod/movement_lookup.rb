module CfWod
  class MovementLookup
    # Brand names for the same equipment category: Assault Bike and Echo Bike are both air bikes,
    # scored identically (calories/distance), so they resolve to the one canonical movement rather
    # than fragmenting PR tracking across three near-duplicate entries. Keys are already normalized
    # (lowercase, trimmed) -- see #alias_match.
    ALIASES = {
      'bike' => 'Air Bike',
      'assault bike' => 'Air Bike',
      'echo bike' => 'Air Bike'
    }.freeze

    TRAILING_PARENTHETICAL = /\s*\([^)]*\)\z/
    PG_TRAILING_PARENTHETICAL = '\s*\([^)]*\)$'.freeze

    def self.call(name) = new(name).lookup

    def initialize(name)
      @name = name
    end

    def lookup
      alias_match || exact_match || singularized_match
    end

    private

    attr_reader :name

    def alias_match
      canonical = ALIASES[base_name]
      Movement.find_by('LOWER(name) = ?', canonical.downcase) if canonical
    end

    def exact_match
      find_with(base_name)
    end

    def singularized_match
      find_with(base_name.singularize)
    end

    # The catalog is inconsistent about whether a compound term is hyphenated (e.g. "Wall-ball
    # Shot") or fully spaced (e.g. "Toes to Bar"), while prose almost always hyphenates compounds
    # like "toes-to-bars" as a single token -- but sometimes uses a space instead where the
    # catalog hyphenates (e.g. "push ups" vs "Push-up"). Try three progressively looser
    # comparisons in order: preserve the candidate's own hyphens first, then flatten only the
    # candidate's hyphens to spaces, then (loosest) flatten hyphens AND strip a trailing
    # parenthetical annotation on the CATALOG side too (e.g. "Single-leg Squat (Pistol)"), so an
    # exact or hyphen-preserving match still wins first when one exists.
    def find_with(candidate)
      find_by_normalized_name(candidate, /\s+/) || find_by_normalized_name(candidate, /[\s-]+/) ||
        find_by_flattened_name(candidate)
    end

    def find_by_normalized_name(candidate, word_separator)
      Movement.find_by('LOWER(name) = ?', normalized(candidate, word_separator))
    end

    def find_by_flattened_name(candidate)
      Movement.find_by(
        "LOWER(REGEXP_REPLACE(REPLACE(name, '-', ' '), ?, '')) = ?",
        PG_TRAILING_PARENTHETICAL, normalized(candidate, /[\s-]+/)
      )
    end

    # Lowercased and stripped of a trailing period/parenthetical, but NOT singularized here --
    # singularizing unconditionally (the previous behavior) mangles inherently-plural compound
    # names like "Knees-to-elbows" into "Knees-to-elbow", breaking their own exact match. Trying
    # the exact form first (see #lookup) and only falling back to the singularized form preserves
    # both: "power snatches" still finds "Power Snatch" via the fallback, and "knees-to-elbows"
    # finds "Knees-to-elbows" directly without ever needing it.
    def base_name
      name.to_s.strip.delete_suffix('.').downcase.sub(TRAILING_PARENTHETICAL, '')
    end

    def normalized(candidate, word_separator)
      candidate.split(word_separator).join(' ')
    end
  end
end
