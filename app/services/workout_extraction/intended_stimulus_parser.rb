module WorkoutExtraction
  # Reads a persisted workout's intended_stimulus_notes prose and fills the structured
  # stimulus columns (stimulus_source: :extracted) via one LLM call. Rows that already carry
  # an :authored value are left alone. Raises ExtractionError on an LLM/parse failure so the
  # caller can decide whether that is fatal -- the scrape path treats it as best-effort.
  class IntendedStimulusParser
    class ExtractionError < StandardError; end

    MODEL = 'claude-haiku-4-5'.freeze
    MAX_TOKENS = 1024
    LOADINGS = IntendedStimulus::LOADINGS.keys.map(&:to_s).freeze

    def self.call(workout, logger: nil) = new(workout, logger: logger).parse

    def initialize(workout, logger: nil)
      @workout = workout
      @logger = logger
    end

    def parse
      return if workout.intended_stimulus_notes.blank?

      data = fetch
      apply_range(data)
      apply_movements(data[:movements] || [])
      workout
    rescue Anthropic::Errors::APIStatusError, Anthropic::Errors::APIConnectionError => e
      log("Anthropic API error: #{e.message}")
      raise ExtractionError, "Anthropic API error: #{e.message}"
    rescue JSON::ParserError => e
      log("malformed JSON from Anthropic: #{e.message}")
      raise ExtractionError, "malformed JSON from Anthropic: #{e.message}"
    end

    private

    attr_reader :workout, :logger

    def fetch
      response = client.messages.create(
        model: MODEL, max_tokens: MAX_TOKENS,
        system: IntendedStimulusPrompt.text,
        messages: [{ role: 'user', content: user_content }]
      )
      block = response.content.find { |content_block| content_block.type == :text }
      raise ExtractionError, 'no text content in Anthropic response' unless block

      JSON.parse(strip_fences(block.text), symbolize_names: true)
    end

    def apply_range(data)
      bounds = [data[:range_low], data[:range_high]].filter_map { |value| positive_int(value) }.sort
      return if bounds.empty?

      low, high = bounds.one? ? [nil, bounds.first] : [bounds.first, bounds.last]
      workout.update!(stimulus_range_low: low, stimulus_range_high: high, stimulus_source: :extracted)
    end

    def apply_movements(entries)
      entries.each do |entry|
        attrs = movement_attrs(entry)
        next if attrs.empty?

        exercises_named(entry[:movement_name]).each do |exercise|
          exercise.update!(**attrs, stimulus_source: :extracted) unless exercise.stimulus_source_authored?
        end
      end
    end

    def movement_attrs(entry)
      {
        stimulus_loading: (entry[:loading].to_s if LOADINGS.include?(entry[:loading].to_s)),
        stimulus_sets_max: positive_int(entry[:sets_max]),
        stimulus_duration_max: positive_int(entry[:duration_max_seconds])
      }.compact
    end

    def exercises_named(name)
      return [] if name.blank?

      workout.segments.flat_map(&:exercises).select { |exercise| exercise.movement.name.casecmp?(name.to_s) }
    end

    def positive_int(value)
      integer = Integer(value, exception: false)
      integer if integer&.positive?
    end

    def strip_fences(text)
      blocks = text.scan(/```(?:json)?\s*\n?(.*?)\n?```/m).flatten
      (blocks.last || text).strip
    end

    def user_content
      movements = workout.segments.flat_map(&:exercises).map do |exercise|
        reps = exercise.reps.to_i
        "- #{exercise.movement.name}#{" x#{reps}" if reps.positive?}"
      end.uniq
      <<~TEXT
        Score type: #{workout.score_type}
        Movements:
        #{movements.join("\n")}

        Stimulus and Strategy:
        #{workout.intended_stimulus_notes}
      TEXT
    end

    def client
      @client ||= Anthropic::Client.new(api_key: Rails.application.credentials.dig(:anthropic, :api_key))
    end

    def log(message)
      logger&.info("[WorkoutExtraction::IntendedStimulusParser] #{message}")
    end
  end
end
