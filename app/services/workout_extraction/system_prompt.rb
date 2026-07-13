module WorkoutExtraction
  # The system prompts sent to the LLM for the two-call workout-text extraction (see LlmParser).
  # Kept out of LlmParser so their size doesn't inflate the orchestration class -- this is prose,
  # not logic.
  module SystemPrompt
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

    def self.workout_shape_text
      <<~PROMPT
        You read CrossFit workout prose and extract its overall shape: workout-level details, any
        named segments, and an ordered list of exercise text snippets. You do not need to fully
        structure each exercise yet -- only recognize where one movement's own prescription starts
        and ends within the text.

        Respond with ONLY a JSON object -- no other text, no markdown code fences -- matching exactly
        this shape:
        {
          "extractable": <boolean, required>,
          "gap_reason": "<string, only when extractable is false>",
        #{workout_field_lines},
          "segments": [
            {
              "name": "<string, required>",
        #{segment_field_lines}
            }
          ],
          "exercise_snippets": [
            { "text": "<string, required>", "segment_index": <integer, only if the exercise belongs to a segment> }
          ]
        }

        If you can confidently represent the workout with this schema, set "extractable" to true and
        fill in the fields below. If you cannot -- the scoring doesn't fit any valid "score_type", or
        the workout's structure genuinely can't be broken into segments and exercise snippets -- set
        "extractable" to false, explain why in "gap_reason", and leave every other field out. Do not
        guess or force a fit; an honest "extractable": false is far more useful than a wrong workout.

        Rules (when "extractable" is true):
        - "score_type" must be exactly one of: #{Metric.workout_measurements.join(', ')}. Use "time" for
          for-time workouts, "rep" for AMRAP/max-rep workouts scored by total reps, "round" for
          rounds-for-time or max-rounds workouts, "weight" for max-load workouts, "calorie" for
          calorie-based workouts.
        - "interval" holds a rep scheme like "21-15-9" when the workout is an ascending or descending
          rep ladder shared across every movement in a round; leave it out otherwise. Keep this rep
          scheme out of the individual exercise snippets -- it belongs here, once, at the workout level.
        - "rounds" is a fixed round count (e.g. "5 rounds for time"); leave it out for AMRAPs, single-round
          workouts, or interval-ladder workouts (use "interval" instead).
        - "time" is a time cap or AMRAP duration in seconds; "time_cap" is a "MM:SS" string cap on a
          for-time workout, independent of "time".
        - Use "segments" only when the workout has multiple distinct labeled parts (e.g. "Part A" / "Part B").
          Most single-block workouts need no segments at all.
        - "exercise_snippets" is an ordered list, one entry per movement mentioned, in the order they
          appear in the source text. Each entry's "text" is just that one movement's own prescription
          phrase (e.g. "21-15-9 Thrusters (95/65) Pull-ups" becomes two snippets, "Thrusters (95/65)"
          and "Pull-ups" -- the shared "21-15-9" goes in the workout-level "interval" field above, not
          in either snippet). Include "segment_index" (the 0-based index into "segments") only when
          the exercise belongs to a segment; leave it out entirely for a top-level exercise.
        - Only include a field when the source text specifies it; omit fields you're not confident
          about rather than guessing a value.

        #{PRESCRIPTION_CHEAT_SHEET}
      PROMPT
    end

    def self.exercise_details_text
      <<~PROMPT
        You convert a numbered list of CrossFit exercise prescription snippets into structured JSON,
        one entry per snippet, in the same order.

        Respond with ONLY a JSON object -- no other text, no markdown code fences -- matching exactly
        this shape:
        {
          "exercises": [
            {
              "movement_name": "<string, required -- copied verbatim from the recognized list below>",
        #{exercise_field_lines}
            }
          ]
        }

        Rules:
        - "movement_name" must be copied verbatim from this exact list of recognized movements (case
          and spelling matter):
          #{Movement.pluck(:name).sort.join(', ')}
          A minor spelling or plural/singular variation still counts as a match.
        - Only include a field when the snippet specifies it; omit fields you're not confident about
          rather than guessing a value.

        #{PRESCRIPTION_CHEAT_SHEET}
      PROMPT
    end

    # Builds a prompt field-description list directly from a schema's properties, so the prompt
    # can't silently drift from the underlying model the way a hand-written description could.
    def self.field_lines(properties, indent: '      ')
      properties.map do |name, property|
        type_hint = property[:enum] ? property[:enum].map(&:inspect).join('/') : property[:type]
        "#{indent}\"#{name}\": <#{type_hint}, omit if not specified>"
      end.join(",\n")
    end

    def self.exercise_field_lines
      field_lines(WorkoutExtraction::LlmParser::EXERCISE_SCHEMA[:properties].except(:movement_name))
    end

    def self.workout_field_lines
      field_lines(WorkoutExtraction::LlmParser::WORKOUT_SHAPE_SCHEMA[:properties]
        .except(:extractable, :gap_reason, :segments, :exercise_snippets), indent: '  ')
    end

    def self.segment_field_lines
      field_lines(WorkoutExtraction::LlmParser::SEGMENT_OUTLINE_SCHEMA[:properties].except(:name))
    end
  end
end
