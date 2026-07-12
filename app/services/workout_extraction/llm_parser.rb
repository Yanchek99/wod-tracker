module WorkoutExtraction
  class LlmParser
    class ExtractionError < StandardError; end
    class UnrepresentableWorkoutError < StandardError; end

    MODEL = 'claude-haiku-4-5'.freeze
    MAX_TOKENS = 2048

    # Anthropic's structured-outputs grammar compiler caps both how many *optional* (non-required)
    # properties a schema can have (limit 24) and how many *nullable/union-typed* properties it can
    # have (limit 16). Exercise is nested in two places (segments[].exercises and the top-level
    # exercises array), so it's defined once here and referenced via $defs/$ref rather than embedded
    # twice; its fields are still the single biggest contributor, so they're the one group split
    # between both buckets -- everything else fits in a single bucket without needing a split.
    def self.nullable(properties)
      properties.transform_values { |property| { anyOf: [property, { type: 'null' }] } }
    end
    private_class_method :nullable

    EXERCISE_REF = { '$ref' => '#/$defs/exercise' }.freeze
    SEGMENT_REF = { '$ref' => '#/$defs/segment' }.freeze

    EXERCISE_SCHEMA = begin
      detail_properties = ModelSchema.properties_for(
        Exercise, except: %w[id workout_id movement_id segment_id created_at updated_at position]
      )
      nullable_fields = %w[reps duration_seconds load female_load male_load distance calories notes]
      properties = detail_properties.except(*nullable_fields.map(&:to_sym))
                                    .merge(nullable(detail_properties.slice(*nullable_fields.map(&:to_sym))))
                                    .merge(movement_name: { type: 'string' })

      {
        type: 'object',
        properties: properties,
        required: nullable_fields + ['movement_name'],
        additionalProperties: false
      }
    end.freeze

    SEGMENT_SCHEMA = begin
      properties = ModelSchema.properties_for(Segment, except: %w[id workout_id created_at updated_at position])
                              .merge(exercises: { type: 'array', items: EXERCISE_REF })

      {
        type: 'object',
        properties: properties,
        required: %w[name exercises],
        additionalProperties: false
      }
    end.freeze

    SCHEMA = begin
      detail_properties = ModelSchema.properties_for(
        Workout,
        except: %w[id created_at updated_at content_key time_cap_seconds],
        overrides: {
          # Narrower than Workout's full score_type enum: only these 5 values are valid workout scores.
          score_type: { type: 'string', enum: Metric.workout_measurements.map(&:to_s) },
          time_cap: { type: 'string' }, # virtual setter (accepts "MM:SS"), not the time_cap_seconds column
          notes: { type: 'string' } # Workout#notes is ActionText, not a plain column
        }
      )
      # name/score_type are the only Workout detail fields conditional on extractable (absent when
      # the LLM declines), so only they need the required-but-nullable treatment; the rest are
      # independently optional exactly as before the gap-reporting feature.
      nullable_fields = %w[name score_type]
      properties = detail_properties.except(*nullable_fields.map(&:to_sym))
                                    .merge(nullable(detail_properties.slice(*nullable_fields.map(&:to_sym))))
                                    .merge(
                                      segments: { type: 'array', items: SEGMENT_REF },
                                      exercises: { type: 'array', items: EXERCISE_REF },
                                      extractable: { type: 'boolean' },
                                      gap_reason: { anyOf: [{ type: 'string' }, { type: 'null' }] }
                                    )

      {
        type: 'object',
        properties: properties,
        required: nullable_fields + %w[segments exercises extractable gap_reason],
        additionalProperties: false,
        '$defs' => { 'exercise' => EXERCISE_SCHEMA, 'segment' => SEGMENT_SCHEMA }
      }
    end.freeze

    def self.call(text) = new(text).parse

    def initialize(text)
      @text = text
    end

    def parse
      attrs = fetch_structured_attrs
      raise_unrepresentable!(attrs) unless attrs[:extractable]

      workout = build_workout(attrs)
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

    def fetch_structured_attrs
      response = client.messages.create(
        model: MODEL,
        max_tokens: MAX_TOKENS,
        system: SystemPrompt.text,
        messages: [{ role: 'user', content: text }],
        output_config: { format: { type: 'json_schema', schema: SCHEMA } }
      )
      text_block = response.content.find { |block| block.type == :text }
      raise ExtractionError, 'no text content in Anthropic response' unless text_block

      JSON.parse(text_block.text, symbolize_names: true)
    rescue JSON::ParserError => e
      raise ExtractionError, "malformed JSON from Anthropic: #{e.message}"
    end

    def build_workout(attrs)
      workout_attrs = attrs.slice(:name, :score_type, :rounds, :time, :interval, :time_cap,
                                  :ladder_step, :team_size, :notes).compact
      workout = Workout.new(workout_attrs)
      segments = attrs[:segments] || []
      build_segments(workout, segments)
      build_exercises(workout, attrs[:exercises] || [], segment: nil, position_offset: segments.size)
      workout
    end

    def build_segments(workout, segments)
      segments.each_with_index do |segment_attrs, index|
        segment = workout.segments.build(
          name: segment_attrs[:name], rounds: segment_attrs[:rounds],
          time_seconds: segment_attrs[:time_seconds], interval_scheme: segment_attrs[:interval_scheme],
          rest_seconds: segment_attrs[:rest_seconds], notes: segment_attrs[:notes], position: index + 1
        )
        build_exercises(workout, segment_attrs[:exercises] || [], segment: segment, position_offset: 0)
      end
    end

    def build_exercises(workout, exercises, segment:, position_offset:)
      exercises.each_with_index do |exercise_attrs, index|
        movement = lookup_movement!(exercise_attrs[:movement_name])
        workout.exercises.build(
          exercise_attrs.except(:movement_name).merge(movement: movement, segment: segment,
                                                      position: position_offset + index + 1)
        )
      end
    end

    def lookup_movement!(name)
      CfWod::MovementLookup.call(name) || raise(ExtractionError, "unrecognized movement: #{name.inspect}")
    end

    def raise_unrepresentable!(attrs)
      reason = attrs[:gap_reason].presence || 'the LLM reported the workout as unrepresentable with no reason given'
      raise UnrepresentableWorkoutError, reason
    end

    def validate_workout!(workout)
      raise ExtractionError, "built workout failed validation: #{workout.errors.full_messages.join(', ')}" unless workout.valid?
    end
  end
end
