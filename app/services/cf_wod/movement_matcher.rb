module CfWod
  class MovementMatcher
    Result = Data.define(:movement, :ambiguous)

    CONNECTOR_WORDS = %w[and to the a of].freeze
    # Real movement names in the catalog are 1-4 words; a longer candidate is very likely a
    # misclassified sentence (e.g. an unrecognized header), not a genuinely new movement -- refuse
    # to create it rather than polluting the catalog with garbage.
    MAX_NEW_MOVEMENT_WORDS = 5

    def self.match(raw_name) = new(raw_name).match

    def initialize(raw_name)
      @raw_name = raw_name
    end

    def match
      singular = normalize(raw_name)
      return Result.new(movement: nil, ambiguous: false) if singular.blank?

      exact = exact_match
      return Result.new(movement: exact, ambiguous: false) if exact

      fuzzy_match(singular)
    end

    private

    attr_reader :raw_name

    # Some catalog names are inherently plural ("Knees-to-elbows") or space- rather than
    # hyphen-separated ("Toes to Bar"), so singularizing before checking for an exact match can
    # miss them. Try the as-written form and a hyphen/space swap before falling back to the
    # singularized form and, failing that, fuzzy search.
    def exact_match
      candidates.filter_map { |candidate| find_exact(candidate) }.first
    end

    def candidates
      words = tokenize(raw_name)
      as_written = title_case(words)
      singular = title_case(words.map { |word| singularize(word) })

      [as_written, singular, as_written.tr('-', ' '), singular.tr('-', ' ')].uniq
    end

    def find_exact(candidate)
      return nil if candidate.blank?

      Movement.where('lower(name) = ?', candidate.downcase).first
    end

    def fuzzy_match(candidate)
      fuzzy_matches = Movement.search_by_name(candidate).to_a

      case fuzzy_matches.size
      when 0 then Result.new(movement: create_if_plausible(candidate), ambiguous: false)
      when 1 then Result.new(movement: fuzzy_matches.first, ambiguous: false)
      else Result.new(movement: nil, ambiguous: true)
      end
    end

    def create_if_plausible(candidate)
      return nil if candidate.split.size > MAX_NEW_MOVEMENT_WORDS

      Movement.find_or_create_by(name: candidate)
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
        index.positive? && CONNECTOR_WORDS.include?(word.downcase) ? word.downcase : capitalize(word)
      end.join(' ')
    end

    def capitalize(word)
      return word if word.empty?

      word[0].upcase + word[1..].downcase
    end
  end
end
