module CfWod
  class MovementMatcher
    Result = Data.define(:movement, :ambiguous)

    CONNECTOR_WORDS = %w[and to the a of].freeze

    def self.match(raw_name) = new(raw_name).match

    def initialize(raw_name)
      @raw_name = raw_name
    end

    def match
      singular = normalize(raw_name)
      return Result.new(movement: nil, ambiguous: false) if singular.blank?

      exact = exact_match(singular)
      return Result.new(movement: exact, ambiguous: false) if exact

      fuzzy_match(singular)
    end

    private

    attr_reader :raw_name

    # Some catalog names are inherently plural ("Knees-to-elbows") or space- rather than
    # hyphen-separated ("Toes to Bar"), so singularizing before checking for an exact match can
    # miss them. Try the as-written form and a hyphen/space swap before falling back to the
    # singularized form and, failing that, fuzzy search.
    def exact_match(singular)
      candidates(singular).filter_map { |candidate| find_exact(candidate) }.first
    end

    def candidates(singular)
      as_written = title_case(tokenize(raw_name))

      [as_written, singular, as_written.tr('-', ' '), singular.tr('-', ' ')].uniq
    end

    def find_exact(candidate)
      return nil if candidate.blank?

      Movement.where('lower(name) = ?', candidate.downcase).first
    end

    # Zero fuzzy matches means the movement isn't in the catalog. Do not create it here --
    # a name the parser lifted from prose (a mis-split line, a named WOD's title, a typo) is not
    # a trustworthy source for a new catalog entry. Report it as unmatched so the caller can flag
    # the parse as needing review instead.
    def fuzzy_match(candidate)
      fuzzy_matches = Movement.search_by_name(candidate).to_a

      case fuzzy_matches.size
      when 1 then Result.new(movement: fuzzy_matches.first, ambiguous: false)
      when 0 then Result.new(movement: nil, ambiguous: false)
      else Result.new(movement: nil, ambiguous: true)
      end
    end

    def normalize(name)
      title_case(tokenize(name).map { |word| singularize(word) })
    end

    def tokenize(name)
      name.to_s.strip.split(/\s+/)
    end

    def singularize(word)
      return word.delete_suffix('es') if word.match?(/(?:ch|sh|x|ss)es\z/i)
      return word if word.end_with?('ss') || !word.end_with?('s')

      word.delete_suffix('s')
    end

    def title_case(words)
      words.each_with_index.map do |word, index|
        index.positive? && CONNECTOR_WORDS.include?(word.downcase) ? word.downcase : word.capitalize
      end.join(' ')
    end
  end
end
