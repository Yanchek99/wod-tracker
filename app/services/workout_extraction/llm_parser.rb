module WorkoutExtraction
  class LlmParser
    class ExtractionError < StandardError; end
    class UnrepresentableWorkoutError < StandardError; end

    MODEL = 'claude-haiku-4-5'.freeze
    MAX_TOKENS = 2048

    # Anthropic's structured-outputs grammar compiler caps how many *optional* (non-required)
    # properties a schema can have (limit 24), how many *nullable/union-typed* properties it can have
    # (limit 16), separately rejects schemas that are too large/deeply nested ("Schema is too
    # complex"), and can time out compiling a schema outright ("Grammar compilation timed out") --
    # observed specifically after union types (anyOf) were used inside array item schemas, which is
    # consistent with union-typed array elements requiring the compiler to account for a much larger
    # combined state space than a flat optional field would. So: extraction is split into two calls
    # (one for the workout's shape -- segments, exercise text snippets, no per-exercise detail --
    # and one that structures every snippet into a full exercise in a single flat array), and every
    # field in both schemas is a single, non-union type: required where the field is unconditionally
    # present, plainly optional (omittable) everywhere else. No anyOf/nullable types anywhere.
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

    EXERCISE_SCHEMA = {
      type: 'object',
      properties: ModelSchema.properties_for(
        Exercise,
        except: %w[id workout_id movement_id segment_id created_at updated_at position],
        overrides: { movement_name: { type: 'string' } }
      ),
      required: %w[movement_name],
      additionalProperties: false
    }.freeze

    EXERCISE_DETAILS_SCHEMA = {
      type: 'object',
      properties: { exercises: { type: 'array', items: EXERCISE_SCHEMA } },
      required: %w[exercises],
      additionalProperties: false
    }.freeze

    def self.call(text) = new(text).parse

    def initialize(text)
      @text = text
    end

    def parse
      shape = fetch_workout_shape
      raise_unrepresentable!(shape) unless shape[:extractable]

      snippets = shape[:exercise_snippets] || []
      exercise_details = snippets.empty? ? [] : fetch_exercise_details(snippets)

      workout = build_workout(shape, snippets, exercise_details)
      validate_workout!(workout)
      workout
    rescue Anthropic::Errors::APIStatusError, Anthropic::Errors::APIConnectionError => e
      raise ExtractionError, "Anthropic API error: #{e.message}"
    end

    private

    attr_reader :text

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
        messages: [{ role: 'user', content: numbered_snippets }],
        output_config: { format: { type: 'json_schema', schema: EXERCISE_DETAILS_SCHEMA } }
      )
      parse_json_response(response)[:exercises]
    end

    def parse_json_response(response)
      text_block = response.content.find { |block| block.type == :text }
      raise ExtractionError, 'no text content in Anthropic response' unless text_block

      JSON.parse(text_block.text, symbolize_names: true)
    rescue JSON::ParserError => e
      raise ExtractionError, "malformed JSON from Anthropic: #{e.message}"
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
