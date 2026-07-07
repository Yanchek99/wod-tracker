module CfWod
  class MovementLookup
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
      base.split.map { |word| word.sub(/\A\w/, &:upcase) }.join(' ')
    end
  end
end
