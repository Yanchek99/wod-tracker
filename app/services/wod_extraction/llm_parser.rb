module WodExtraction
  class LlmParser
    class ExtractionError < StandardError; end

    MODEL = 'claude-haiku-4-5'.freeze
    MAX_TOKENS = 2048

    EXERCISE_SCHEMA = {
      type: 'object',
      properties: {
        movement_name: { type: 'string' },
        position: { type: 'integer' },
        reps: { type: 'integer' },
        duration_seconds: { type: 'integer' },
        load: { type: 'number' },
        female_load: { type: 'number' },
        male_load: { type: 'number' },
        implement_count: { type: 'integer' },
        distance: { type: 'number' },
        female_distance: { type: 'number' },
        male_distance: { type: 'number' },
        distance_unit: { type: 'string' },
        distance_units_per_rep: { type: 'number' },
        calories: { type: 'integer' },
        female_calories: { type: 'integer' },
        male_calories: { type: 'integer' },
        ladder_step_every: { type: 'integer' },
        ladder_exempt: { type: 'boolean' },
        notes: { type: 'string' }
      },
      required: %w[movement_name position],
      additionalProperties: false
    }.freeze

    SEGMENT_SCHEMA = {
      type: 'object',
      properties: {
        name: { type: 'string' },
        rounds: { type: 'integer' },
        time_seconds: { type: 'integer' },
        interval_scheme: { type: 'string' },
        rest_seconds: { type: 'integer' },
        notes: { type: 'string' },
        exercises: { type: 'array', items: EXERCISE_SCHEMA }
      },
      required: %w[name exercises],
      additionalProperties: false
    }.freeze

    SCHEMA = {
      type: 'object',
      properties: {
        name: { type: 'string' },
        score_type: { type: 'string', enum: Metric.workout_measurements.map(&:to_s) },
        rounds: { type: 'integer' },
        time: { type: 'integer' },
        interval: { type: 'string' },
        time_cap: { type: 'string' },
        ladder_step: { type: 'integer' },
        team_size: { type: 'integer' },
        notes: { type: 'string' },
        segments: { type: 'array', items: SEGMENT_SCHEMA },
        exercises: { type: 'array', items: EXERCISE_SCHEMA }
      },
      required: %w[name score_type segments exercises],
      additionalProperties: false
    }.freeze

    PRESCRIPTION_CHEAT_SHEET = <<~CHEATSHEET.freeze
      Common notation:
      - "21-15-9" = an ascending/descending rep ladder across rounds (interval).
      - "5 RFT" = 5 rounds for time (rounds: 5, score_type: "round" is wrong here -- use "time").
      - "AMRAP 20" = as many rounds/reps as possible in 20 minutes (time: 1200; score_type "round" if
        scored by full rounds, "rep" if scored by total reps including partial rounds).
      - "EMOM 10" = every minute on the minute for 10 minutes; a fixed-work-per-interval workout.
      - Loads written "95/65" are male/female (male_load/female_load); a single number applies to both
        sexes equally via "load".
    CHEATSHEET

    def self.call(text) = new(text).parse

    def initialize(text)
      @text = text
    end

    def parse
      attrs = fetch_structured_attrs
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
        system: system_prompt,
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
      build_segments(workout, attrs[:segments] || [])
      build_exercises(workout, attrs[:exercises] || [], segment: nil, position_offset: 0)
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

    def validate_workout!(workout)
      raise ExtractionError, "built workout failed validation: #{workout.errors.full_messages.join(', ')}" unless workout.valid?
    end

    def system_prompt
      <<~PROMPT
        You convert CrossFit workout ("WOD") prose into structured JSON matching the provided schema.

        Rules:
        - "score_type" must be exactly one of: #{Metric.workout_measurements.join(', ')}. Use "time" for
          for-time workouts, "rep" for AMRAP/max-rep workouts scored by total reps, "round" for
          rounds-for-time or max-rounds workouts, "weight" for max-load workouts, "calorie" for
          calorie-based workouts.
        - "interval" holds a rep scheme like "21-15-9" when the workout is an ascending or descending
          rep ladder across rounds; leave it out otherwise.
        - "rounds" is a fixed round count (e.g. "5 rounds for time"); leave it out for AMRAPs, single-round
          workouts, or interval-ladder workouts (use "interval" instead).
        - "time" is a time cap or AMRAP duration in seconds; "time_cap" is a "MM:SS" string cap on a
          for-time workout, independent of "time".
        - Use "segments" only when the workout has multiple distinct labeled parts (e.g. "Part A" / "Part B",
          or a warm-up and a WOD you're asked to structure). Most single-block WODs should list their
          movements directly under top-level "exercises" with no segments.
        - "movement_name" must be copied verbatim from this exact list of recognized movements (case and
          spelling matter):
          #{Movement.pluck(:name).sort.join(', ')}
          If a movement in the text isn't in this list, pick the closest exact match from the list --
          never invent a name that isn't on it.
        - Only include a field when the source text specifies it; omit fields you're not confident about
          rather than guessing a value.

        #{PRESCRIPTION_CHEAT_SHEET}
      PROMPT
    end
  end
end
