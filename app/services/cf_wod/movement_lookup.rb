module CfWod
  class MovementLookup
    # Minor connector words the catalog's own naming leaves lowercase mid-phrase (e.g. "Clean and
    # Jerk", "Power Clean and Split Jerk") -- standard English title-case convention, not specific
    # to this app. Still capitalized as the first word of a name.
    CONNECTOR_WORDS = %w[and to of the a an or].freeze

    def self.call(name) = new(name).lookup

    def initialize(name)
      @name = name
    end

    def lookup
      Movement.find_by(name: normalized_name)
    end

    private

    attr_reader :name

    def normalized_name
      base = name.to_s.strip.delete_suffix('.').downcase.singularize
      base.split.each_with_index.map { |word, index| titlecase_word(word, first: index.zero?) }.join(' ')
    end

    def titlecase_word(word, first:)
      return word if !first && CONNECTOR_WORDS.include?(word)

      word.sub(/\A\w/, &:upcase)
    end
  end
end
