module CfWod
  class MovementLookup
    def self.call(name) = new(name).lookup

    def initialize(name)
      @name = name
    end

    def lookup
      find_by_normalized_name(/\s+/) || find_by_normalized_name(/[\s-]+/)
    end

    private

    attr_reader :name

    def find_by_normalized_name(word_separator)
      # Movement validates case-insensitive name uniqueness, so this can match at most one row.
      Movement.find_by('LOWER(name) = ?', normalized_name(word_separator))
    end

    # The catalog is inconsistent about whether a compound term is hyphenated (e.g. "Wall-ball
    # Shot") or fully spaced (e.g. "Toes to Bar"), while prose always hyphenates compounds like
    # "toes-to-bars" as a single token. Try splitting on whitespace only first (preserving any
    # internal hyphen, matching the "Wall-ball" style); only if that misses, retry splitting on
    # hyphens too, so a fully-spaced catalog entry can still be found.
    def normalized_name(word_separator)
      base = name.to_s.strip.delete_suffix('.').downcase.singularize
      base.split(word_separator).join(' ')
    end
  end
end
