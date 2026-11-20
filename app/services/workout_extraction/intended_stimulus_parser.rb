module WorkoutExtraction
  # Reads a persisted workout's intended_stimulus_notes prose and fills the structured
  # stimulus columns (stimulus_source: :extracted) via one LLM call. Rows that already carry
  # an :authored value are left alone; an already-extracted workout is re-extracted only
  # when forced. A successful call always stamps the workout :extracted, even when the prose
  # held nothing structurable, so a backfill doesn't re-spend the call on it. Raises
  # ExtractionError on an LLM/parse failure so the caller can decide whether that is fatal --
  # the scrape path treats it as best-effort.
  class IntendedStimulusParser
    class ExtractionError < StandardError; end

    MODEL = 'claude-haiku-4-5'.freeze
    MAX_TOKENS = 1024

    def self.call(workout, logger: nil, force: false) = new(workout, logger:, force:).parse

    def initialize(workout, logger: nil, force: false)
      @workout = workout
      @logger = logger
      @force = force
    end

    def parse
      return unless extractable?

      apply(fetch)
      workout
    rescue Anthropic::Errors::APIStatusError, Anthropic::Errors::APIConnectionError => e
      log("Anthropic API error: #{e.message}")
      raise ExtractionError, "Anthropic API error: #{e.message}"
    rescue JSON::ParserError => e
      log("malformed JSON from Anthropic: #{e.message}")
      raise ExtractionError, "malformed JSON from Anthropic: #{e.message}"
    end

    private

    attr_reader :workout, :logger, :force

    def extractable?
      return false if workout.intended_stimulus_notes.blank? || workout.stimulus_source_authored?

      force || !workout.stimulus_source_extracted?
    end

    def fetch
      response = client.messages.create(
        model: MODEL, max_tokens: MAX_TOKENS,
        system: IntendedStimulusPrompt.text,
        messages: [{ role: 'user', content: user_content }]
      )
      block = response.content.find { |content_block| content_block.type == :text }
      raise ExtractionError, 'no text content in Anthropic response' unless block

      data = JSON.parse(strip_fences(block.text), symbolize_names: true)
      raise ExtractionError, 'Anthropic response JSON is not an object' unless data.is_a?(Hash)

      data
    end

    def apply(data)
      Workout.transaction do
        workout.update!(**IntendedStimulusFields.workout_attrs(data, workout), stimulus_source: :extracted)
        apply_movements(Array(data[:movements]).grep(Hash))
      end
    end

    def apply_movements(entries)
      entries.each do |entry|
        attrs = IntendedStimulusFields.movement_attrs(entry)
        next if attrs.empty?

        exercises_named(entry[:movement_name]).each do |exercise|
          exercise.update!(**attrs, stimulus_source: :extracted) unless exercise.stimulus_source_authored?
        end
      end
    end

    def exercises_named(name)
      return [] if name.blank?

      workout.segments.flat_map(&:exercises).select { |exercise| exercise.movement.name.casecmp?(name.to_s) }
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
