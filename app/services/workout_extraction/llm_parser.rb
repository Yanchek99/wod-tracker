module WorkoutExtraction
  class LlmParser
    class ExtractionError < StandardError; end
    class UnrepresentableWorkoutError < StandardError; end

    MODEL = 'claude-haiku-4-5'.freeze
    MAX_TOKENS = 2048

    # Extraction is a single call: neither this nor the prior two-call version enforces its schema
    # via output_config/json_schema (both triggered Anthropic structured-outputs compiler errors
    # regardless of shape), so there's no longer a compiler-imposed reason to keep the workout's
    # shape and its exercises' details as two separate calls. These methods exist only so
    # SystemPrompt's field descriptions can be derived programmatically instead of hand-written, so
    # they can't silently drift from the Workout/Segment/Exercise models. Keep them lazy because
    # deriving model-backed properties queries table metadata, and worker boot can eager-load this
    # class before a new environment's database has been migrated.
    def self.exercise_schema
      @exercise_schema ||= {
        type: 'object',
        properties: ModelSchema.properties_for(
          Exercise,
          except: %w[id workout_id movement_id segment_id created_at updated_at position notes
                     stimulus_loading stimulus_sets_max stimulus_duration_max stimulus_source],
          overrides: { movement_name: { type: 'string' } }
        ),
        required: %w[movement_name],
        additionalProperties: false
      }.freeze
    end

    def self.segment_schema
      @segment_schema ||= {
        type: 'object',
        properties: ModelSchema.properties_for(Segment, except: %w[id workout_id created_at updated_at position])
                               .merge(exercises: { type: 'array', items: exercise_schema }),
        required: [],
        additionalProperties: false
      }.freeze
    end

    def self.workout_schema
      @workout_schema ||= {
        type: 'object',
        properties: ModelSchema.properties_for(
          Workout,
          except: %w[id created_at updated_at content_key time_cap_seconds
                     stimulus_range_low stimulus_range_high intended_stimulus_notes stimulus_source],
          overrides: workout_schema_overrides
        ).merge(
          segments: { type: 'array', items: segment_schema },
          exercises: { type: 'array', items: exercise_schema },
          extractable: { type: 'boolean' },
          gap_reason: { type: 'string' }
        ),
        required: %w[extractable],
        additionalProperties: false
      }.freeze
    end

    def self.workout_schema_overrides
      {
        # Narrower than Workout's full score_type enum: only these 5 values are valid workout scores.
        score_type: { type: 'string', enum: Metric.workout_measurements.map(&:to_s) },
        time_cap: { type: 'string' }, # virtual setter (accepts "MM:SS"), not the time_cap_seconds column
        notes: { type: 'string' }, # Workout#notes is ActionText, not a plain column
        # Workout no longer stores its own scheme -- every Exercise belongs to a Segment, and a
        # "flat" (no named parts) workout is represented as one implicit segment wrapping its
        # top-level "exercises" (see build_workout). These three route to that segment's
        # rounds/time_seconds/interval_scheme rather than to a Workout column.
        rounds: { type: 'integer' },
        time: { type: 'integer' },
        interval: { type: 'string' }
      }
    end
    private_class_method :workout_schema_overrides

    PRESCRIPTION_VALUE_PATTERN = [
      '\d[\d,]*(?:\.\d+)?',
      '\s*(?:-| )?\s*',
      '(?:m|meters?|ft|feet|foot|in|inches?|mi|miles?|cal|cals|calories?|lb|lbs|pounds?|kg|pood)?'
    ].join.freeze
    LEADING_PRESCRIPTION_LINE = /\A#{PRESCRIPTION_VALUE_PATTERN}\s+.+\s+x\s*\d+\z/i
    REORDERED_PRESCRIPTION_LINE = /\A\d+\s*x\s*#{PRESCRIPTION_VALUE_PATTERN}\s+.+\z/i

    # CrossFit states a shuttle run's length as one leg out and one leg back ("One shuttle run
    # is 25 feet down and 25 feet back"); the per-rep distance is the two legs summed (50 ft).
    # Recovered from the source text because that clause sits apart from the "10 shuttle runs"
    # line and the LLM routinely leaves it only in the workout notes.
    SHUTTLE_RUN_MOVEMENT = 'Shuttle Run'.freeze
    SHUTTLE_RUN_UNIT = 'feet|foot|ft|meters?|metres?|m'.freeze
    SHUTTLE_RUN_LEG_LENGTH =
      /(\d+)\s*-?\s*(#{SHUTTLE_RUN_UNIT})\b[^.\n]*?\bdown\b[^.\n]*?(\d+)\s*-?\s*(?:#{SHUTTLE_RUN_UNIT})?\b[^.\n]*?\bback\b/i

    # logger is opt-in and silent by default (nil) so normal callers don't get unexpected output;
    # pass one (e.g. Logger.new($stdout)) to see progress or where a failure occurred.
    def self.call(text, date:, logger: nil) = new(text, date: date, logger: logger).parse

    def initialize(text, date:, logger: nil)
      @text = text
      @date = date
      @logger = logger
    end

    def parse
      attrs = logged_fetch
      raise_unrepresentable!(attrs) unless attrs[:extractable]

      attrs = normalize_lifting_set_interval(attrs)
      workout = build_workout(attrs)
      backfill_shuttle_run_distance(workout)
      LiftingLoadSentinelMarker.call(workout)
      validate_workout!(workout)
      workout
    rescue Anthropic::Errors::APIStatusError, Anthropic::Errors::APIConnectionError => e
      log("Anthropic API error: #{e.message}")
      raise ExtractionError, "Anthropic API error: #{e.message}"
    rescue ArgumentError => e
      # Raised by Rails' enum setters (score_type, distance_unit) when the LLM outputs a value
      # outside the enum -- schema enforcement no longer prevents this (see the class comment), so
      # this is a real, reachable failure mode rather than a defensive-only rescue.
      log("Invalid attribute value from LLM: #{e.message}")
      raise ExtractionError, "invalid attribute value from LLM: #{e.message}"
    end

    private

    attr_reader :text, :date, :logger

    def logged_fetch
      log('Fetching workout...')
      attrs = fetch_workout
      log("Workout received: extractable=#{attrs[:extractable].inspect}, " \
          "segments=#{attrs[:segments]&.size || 0}, exercises=#{attrs[:exercises]&.size || 0}")
      attrs
    end

    def log(message)
      logger&.info("[WorkoutExtraction::LlmParser] #{message}")
    end

    def client
      @client ||= Anthropic::Client.new(api_key: Rails.application.credentials.dig(:anthropic, :api_key))
    end

    def fetch_workout
      response = client.messages.create(
        model: MODEL,
        max_tokens: MAX_TOKENS,
        system: SystemPrompt.text,
        messages: [{ role: 'user', content: text }]
      )
      parse_json_response(response)
    end

    def parse_json_response(response)
      text_block = response.content.find { |block| block.type == :text }
      raise ExtractionError, 'no text content in Anthropic response' unless text_block

      JSON.parse(strip_markdown_fences(text_block.text), symbolize_names: true)
    rescue JSON::ParserError => e
      raise ExtractionError, "malformed JSON from Anthropic: #{e.message}"
    end

    # The call isn't schema-enforced, so the response isn't guaranteed fence-free. Usually there's
    # at most one ```json fence despite being told not to add one, but the model occasionally
    # second-guesses itself mid-response ("Wait, let me reconsider...") and emits a corrected
    # second block -- take the last fenced block when there's more than one, since that's the
    # model's final answer. A no-op when there's no fence at all.
    def strip_markdown_fences(text)
      blocks = text.scan(/```(?:json)?\s*\n?(.*?)\n?```/m).flatten
      blocks.any? ? blocks.last.strip : text.strip
    end

    def build_workout(attrs)
      workout_attrs = attrs.slice(:name, :score_type, :time_cap, :ladder_step, :team_size, :notes).compact
      workout_attrs[:name] = normalized_name(workout_attrs[:name])
      workout = Workout.new(workout_attrs)

      segments = attrs[:segments] || []
      build_named_segments(workout, segments)
      build_top_level_exercises(workout, attrs, position: segments.size + 1)
      workout
    end

    def normalize_lifting_set_interval(attrs)
      return attrs unless attrs[:score_type].to_s == 'weight'
      return attrs unless set_scheme?(attrs[:interval])
      return attrs unless (attrs[:exercises] || []).one?

      reps_per_set = attrs[:interval].split('-').map(&:to_i)
      exercise = attrs[:exercises].first
      attrs.merge(rounds: fixed_reps_per_set(reps_per_set), interval: nil,
                  exercises: lifting_set_exercises(exercise, reps_per_set))
    end

    def set_scheme?(scheme)
      scheme.to_s.match?(/\A\d+(?:-\d+)+\z/)
    end

    def fixed_reps_per_set(reps_per_set)
      reps_per_set.uniq.one? ? reps_per_set.length : nil
    end

    def lifting_set_exercises(exercise, reps_per_set)
      if reps_per_set.uniq.one?
        [exercise.merge(reps: reps_per_set.first)]
      else
        reps_per_set.map { |reps| exercise.merge(reps: reps) }
      end
    end

    def normalized_name(name)
      return name if name.present? && !prescription_line_name?(name)

      source_title || default_name
    end

    # The workout's title line, recovered from the source when the LLM drops it. CrossFit.com
    # names its workouts ("Community Cup Workout 3", "Murph") on the first content line, above
    # the format header. Returned only when that line reads as a title and a later line carries
    # the workout's own format header, so a plain single-piece prose paste ("20 Thrusters for
    # time") still falls through to the date-based name.
    def source_title
      lines = text.to_s.each_line.map(&:strip).compact_blank
      candidate = lines.first.to_s
      return unless title_like?(candidate)
      return unless lines.drop(1).any? { |line| cf_format_header?(line) }

      candidate
    end

    # The first content line reads as a workout's own name -- not a prescription, a recognized
    # CrossFit format header, a "Part A:"-style label, or a movement -- and is short enough to be
    # a title rather than a run-on sentence.
    def title_like?(line)
      return false if line.blank? || line.length > 60 || line.end_with?(':')
      return false if prescription_line_name?(line) || cf_format_header?(line)

      CfWod::MovementLookup.call(line).nil?
    end

    def cf_format_header?(line)
      CfWod::WorkoutFormatClassifier.call(line)
      true
    rescue CfWod::WorkoutParser::UnparseableError
      false
    end

    def prescription_line_name?(name)
      value = name.to_s.strip

      set_scheme?(value) ||
        value.match?(LEADING_PRESCRIPTION_LINE) ||
        value.match?(REORDERED_PRESCRIPTION_LINE)
    end

    # Matches CfWod::WorkoutParser's convention for unnamed scraped workouts (same slug format).
    def default_name
      "CF-#{date.strftime('%y%m%d')}"
    end

    def build_named_segments(workout, segments)
      segments.each_with_index do |segment_attrs, index|
        segment = workout.segments.build(
          name: segment_attrs[:name], rounds: segment_attrs[:rounds],
          time_seconds: segment_attrs[:time_seconds], interval_scheme: segment_attrs[:interval_scheme],
          rest_seconds: segment_attrs[:rest_seconds], notes: segment_attrs[:notes], position: index + 1
        )
        build_exercises(segment, segment_attrs[:exercises] || [])
      end
    end

    # Every Exercise belongs to a Segment now, so a "flat" workout (no named parts) is a single
    # unnamed segment wrapping the top-level exercises -- the same shape CfWod::WorkoutParser
    # already builds for its own flat/no-header case. The workout's own rounds/time/interval (see
    # workout_schema) land on this segment's rounds/time_seconds/interval_scheme.
    def build_top_level_exercises(workout, attrs, position:)
      exercises = attrs[:exercises] || []
      return if exercises.empty?

      segment = workout.segments.build(
        rounds: attrs[:rounds], time_seconds: attrs[:time], interval_scheme: attrs[:interval], position: position
      )
      build_exercises(segment, exercises)
    end

    def build_exercises(segment, exercises)
      exercises.each_with_index do |exercise_attrs, index|
        movement = lookup_movement!(exercise_attrs[:movement_name])
        attrs = normalize_sex_paired_attrs(exercise_attrs.except(:movement_name))
        segment.exercises.build(attrs.merge(movement: movement, position: index + 1))
      end
    end

    def backfill_shuttle_run_distance(workout)
      prescription = shuttle_run_prescription
      return unless prescription

      workout.segments.flat_map(&:exercises).each do |exercise|
        next unless exercise.movement&.name == SHUTTLE_RUN_MOVEMENT
        next if exercise.distance.present?

        exercise.assign_attributes(prescription)
      end
    end

    def shuttle_run_prescription
      match = text.to_s.match(SHUTTLE_RUN_LEG_LENGTH)
      return unless match

      unit = match[2].downcase.start_with?('m') ? :meter : :foot
      { distance: match[1].to_i + match[3].to_i, distance_unit: unit }
    end

    # Despite the prompt's instruction, the LLM occasionally attaches a stray one-sided
    # female_X/male_X alongside a plain value it also (correctly) set for the same dimension --
    # most often the reps/calories interval placeholder. Drop the sex-specific companions when a
    # plain value is present, matching the prompt's own precedence: "a single number applies to
    # both sexes equally".
    def normalize_sex_paired_attrs(attrs)
      Exercise::SEX_PAIRED_DIMENSIONS.each_with_object(attrs.dup) do |dimension, normalized|
        next if normalized[dimension].blank?

        normalized.delete(:"female_#{dimension}")
        normalized.delete(:"male_#{dimension}")
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
