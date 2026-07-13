module WorkoutExtraction
  class LlmParser
    class ExtractionError < StandardError; end
    class UnrepresentableWorkoutError < StandardError; end

    MODEL = 'claude-haiku-4-5'.freeze
    MAX_TOKENS = 2048

    # Extraction is two calls: one for the workout's shape (segments, exercise text snippets, no
    # per-exercise detail) and one that structures every snippet into full exercise details. The
    # workout-shape call enforces WORKOUT_SHAPE_SCHEMA via output_config/json_schema; the
    # exercise-details call does not enforce EXERCISE_SCHEMA that way (see the comment there) --
    # every prior attempt to satisfy Anthropic's structured-outputs grammar compiler for a rich
    # per-exercise schema (optional-property limits, nullable/union-type limits, "too complex",
    # "grammar compilation timed out") failed specifically on that call, never on the shape call.
    SEGMENT_OUTLINE_SCHEMA = {
      type: 'object',
      properties: ModelSchema.properties_for(Segment, except: %w[id workout_id created_at updated_at position]),
      required: %w[name],
      additionalProperties: false
    }.freeze

    EXERCISE_SNIPPET_SCHEMA = {
      type: 'object',
      properties: {
        text: { type: 'string' },
        segment_index: { type: 'integer' } # omitted entirely for a top-level exercise, not in any segment
      },
      required: %w[text],
      additionalProperties: false
    }.freeze

    WORKOUT_SHAPE_SCHEMA = {
      type: 'object',
      properties: ModelSchema.properties_for(
        Workout,
        except: %w[id created_at updated_at content_key time_cap_seconds],
        overrides: {
          # Narrower than Workout's full score_type enum: only these 5 values are valid workout scores.
          score_type: { type: 'string', enum: Metric.workout_measurements.map(&:to_s) },
          time_cap: { type: 'string' }, # virtual setter (accepts "MM:SS"), not the time_cap_seconds column
          notes: { type: 'string' } # Workout#notes is ActionText, not a plain column
        }
      ).merge(
        segments: { type: 'array', items: SEGMENT_OUTLINE_SCHEMA },
        exercise_snippets: { type: 'array', items: EXERCISE_SNIPPET_SCHEMA },
        extractable: { type: 'boolean' },
        gap_reason: { type: 'string' }
      ),
      required: %w[extractable],
      additionalProperties: false
    }.freeze

    # Every failure above happened in the exercise-details call specifically (this one has never
    # failed); the exercise-details call therefore doesn't enforce this schema via output_config at
    # all -- it's used only to derive the prompt's field descriptions programmatically, so the
    # prompt can't silently drift from the Exercise model. See SystemPrompt#exercise_details_text.
    EXERCISE_SCHEMA = {
      type: 'object',
      properties: ModelSchema.properties_for(
        Exercise,
        except: %w[id workout_id movement_id segment_id created_at updated_at position notes],
        overrides: { movement_name: { type: 'string' } }
      ),
      required: %w[movement_name],
      additionalProperties: false
    }.freeze

    # logger is opt-in and silent by default (nil) so normal callers don't get unexpected output;
    # pass one (e.g. Logger.new($stdout)) to see which of the two calls is in flight when something
    # fails, rather than guessing from the error message alone.
    def self.call(text, logger: nil) = new(text, logger: logger).parse

    def initialize(text, logger: nil)
      @text = text
      @logger = logger
    end

    def parse
      shape = logged_workout_shape
      raise_unrepresentable!(shape) unless shape[:extractable]

      snippets = shape[:exercise_snippets] || []
      exercise_details = snippets.empty? ? [] : logged_exercise_details(snippets)

      workout = build_workout(shape, snippets, exercise_details)
      validate_workout!(workout)
      workout
    rescue Anthropic::Errors::APIStatusError, Anthropic::Errors::APIConnectionError => e
      log("Anthropic API error: #{e.message}")
      raise ExtractionError, "Anthropic API error: #{e.message}"
    end

    private

    attr_reader :text, :logger

    def logged_workout_shape
      log('Fetching workout shape...')
      shape = fetch_workout_shape
      log("Workout shape received: extractable=#{shape[:extractable].inspect}, " \
          "segments=#{shape[:segments]&.size || 0}, exercise_snippets=#{shape[:exercise_snippets]&.size || 0}")
      shape
    end

    def logged_exercise_details(snippets)
      log("Fetching exercise details for #{snippets.size} snippet(s)...")
      details = fetch_exercise_details(snippets)
      log("Exercise details received: #{details.size} entries")
      details
    end

    def log(message)
      logger&.info("[WorkoutExtraction::LlmParser] #{message}")
    end

    def client
      @client ||= Anthropic::Client.new(api_key: Rails.application.credentials.dig(:anthropic, :api_key))
    end

    def fetch_workout_shape
      response = client.messages.create(
        model: MODEL,
        max_tokens: MAX_TOKENS,
        system: SystemPrompt.workout_shape_text,
        messages: [{ role: 'user', content: text }],
        output_config: { format: { type: 'json_schema', schema: WORKOUT_SHAPE_SCHEMA } }
      )
      parse_json_response(response)
    end

    def fetch_exercise_details(snippets)
      numbered_snippets = snippets.each_with_index.map { |snippet, index| "#{index + 1}. #{snippet[:text]}" }.join("\n")
      response = client.messages.create(
        model: MODEL,
        max_tokens: MAX_TOKENS,
        system: SystemPrompt.exercise_details_text,
        messages: [{ role: 'user', content: numbered_snippets }]
      )
      parse_json_response(response)[:exercises]
    end

    def parse_json_response(response)
      text_block = response.content.find { |block| block.type == :text }
      raise ExtractionError, 'no text content in Anthropic response' unless text_block

      JSON.parse(strip_markdown_fences(text_block.text), symbolize_names: true)
    rescue JSON::ParserError => e
      raise ExtractionError, "malformed JSON from Anthropic: #{e.message}"
    end

    # Only the (still schema-enforced) workout-shape call is guaranteed fence-free; the
    # exercise-details call has no such guarantee, so strip a ```json fence if the model added one
    # despite being told not to. A no-op when there's no fence to strip.
    def strip_markdown_fences(text)
      text.strip.sub(/\A```(?:json)?\s*\n?/, '').sub(/\n?```\s*\z/, '')
    end

    def build_workout(shape, snippets, exercise_details)
      workout_attrs = shape.slice(:name, :score_type, :rounds, :time, :interval, :time_cap,
                                  :ladder_step, :team_size, :notes).compact
      workout = Workout.new(workout_attrs)

      segments = build_segments(workout, shape[:segments] || [])
      build_exercises(workout, segments, snippets, exercise_details)
      workout
    end

    def build_segments(workout, segment_shapes)
      segment_shapes.each_with_index.map do |segment_attrs, index|
        workout.segments.build(
          name: segment_attrs[:name], rounds: segment_attrs[:rounds],
          time_seconds: segment_attrs[:time_seconds], interval_scheme: segment_attrs[:interval_scheme],
          rest_seconds: segment_attrs[:rest_seconds], notes: segment_attrs[:notes], position: index + 1
        )
      end
    end

    def build_exercises(workout, segments, snippets, exercise_details)
      raise ExtractionError, "expected #{snippets.size} structured exercises, got #{exercise_details.size}" if snippets.size != exercise_details.size

      position_counters = Hash.new(0)
      position_counters[:top_level] = segments.size

      snippets.each_with_index do |snippet, index|
        build_exercise(workout, segments, snippet, exercise_details[index], position_counters)
      end
    end

    def build_exercise(workout, segments, snippet, exercise_attrs, position_counters)
      movement = lookup_movement!(exercise_attrs[:movement_name])
      segment = snippet[:segment_index] && segments[snippet[:segment_index]]
      counter_key = segment || :top_level
      position_counters[counter_key] += 1

      workout.exercises.build(
        exercise_attrs.except(:movement_name).merge(movement: movement, segment: segment, position: position_counters[counter_key])
      )
    end

    def lookup_movement!(name)
      CfWod::MovementLookup.call(name) || raise(ExtractionError, "unrecognized movement: #{name.inspect}")
    end

    def raise_unrepresentable!(shape)
      reason = shape[:gap_reason].presence || 'the LLM reported the workout as unrepresentable with no reason given'
      raise UnrepresentableWorkoutError, reason
    end

    def validate_workout!(workout)
      raise ExtractionError, "built workout failed validation: #{workout.errors.full_messages.join(', ')}" unless workout.valid?
    end
  end
end
