module WorkoutExtraction
  # The system prompt sent to the LLM for workout-text extraction (see LlmParser). Kept out of
  # LlmParser so its size doesn't inflate the orchestration class -- this is prose, not logic.
  module SystemPrompt
    PRESCRIPTION_CHEAT_SHEET = <<~CHEATSHEET.freeze
      Common notation:
      - "21-15-9" = an ascending/descending rep ladder across rounds (interval).
      - "5 RFT" = 5 rounds for time (rounds: 5, score_type: "round" is wrong here -- use "time").
      - "AMRAP 20" = as many rounds/reps as possible in 20 minutes (time: 1200; score_type "round" if
        scored by full rounds, "rep" if scored by total reps including partial rounds).
      - "EMOM 10" = every minute on the minute for 10 minutes; a fixed-work-per-interval workout.
      - "♀95lb / ♂135lb" (or "Women: 95lb, Men: 135lb") explicitly labels each value -- use the
        symbol/label, not position, to assign female_load/male_load. A bare, unlabeled split like
        "65/95" is female/male (female_load/male_load) -- female value first, male value second.
        A single number applies to both sexes equally via "load".
    CHEATSHEET

    def self.text
      <<~PROMPT
        You convert CrossFit workout prose into structured JSON matching the shape described below.

        Respond with ONLY a JSON object -- no other text, no markdown code fences -- matching exactly
        this shape:
        {
          "extractable": <boolean, required>,
          "gap_reason": "<string, only when extractable is false>",
        #{workout_field_lines},
          "segments": [
            {
              "name": "<string, required>",
        #{segment_field_lines},
              "exercises": [ <exercise, see shape below> ]
            }
          ],
          "exercises": [ <exercise, see shape below> ]
        }

        Each exercise:
        {
          "movement_name": "<string, required -- copied verbatim from the recognized list below>",
        #{exercise_field_lines}
        }

        If you can confidently represent the workout with this schema, set "extractable" to true and
        fill in the fields below. If you cannot -- a movement isn't in the recognized list below with
        no reasonably close match, the scoring doesn't fit any valid "score_type", or the workout's
        structure genuinely can't be represented by "segments"/"exercises" -- set "extractable" to
        false, explain why in "gap_reason", and leave every other field out. Do not guess or force a
        fit; an honest "extractable": false is far more useful than a wrong workout.

        Rules (when "extractable" is true):
        - "score_type" must be exactly one of: #{Metric.workout_measurements.join(', ')}. Use "time" for
          for-time workouts, including rounds-for-time (e.g. "5 RFT") -- these are scored by elapsed
          time, not round count. Use "rep" for AMRAP/max-rep workouts scored by total reps, "round"
          only for AMRAP-style workouts actually scored by rounds completed, "weight" for max-load
          workouts, "calorie" for calorie-based workouts.
        - "interval" holds a rep scheme like "21-15-9" when the workout is an ascending or descending
          rep ladder across rounds; leave it out otherwise.
        - For an exercise driven by an interval scheme (the workout's own "interval", or its
          segment's "interval_scheme"), set that exercise's plain "reps" -- or plain "calories" for
          a calorie-scored movement like a Calorie Row -- to 1, a structural placeholder, never the
          literal first-round number (e.g. not 21 for "21-15-9"), and never as "female_calories"/
          "male_calories" -- a placeholder is never sex-specific, even if the workout has
          sex-specific values elsewhere (e.g. a load on a different movement). The real per-round
          values come from the interval scheme itself, not from a stored count on the exercise.
        - "rounds" is a fixed round count (e.g. "5 rounds for time"); leave it out for AMRAPs, single-round
          workouts, or interval-ladder workouts (use "interval" instead).
        - "time" is a time cap or AMRAP duration in seconds; "time_cap" is a "MM:SS" string cap on a
          for-time workout, independent of "time".
        - Default to no segments: list movements directly under top-level "exercises". Only use
          "segments" when the source text itself names or labels genuinely distinct parts (e.g.
          "Part A:" / "Part B:", or a separate "Buy-in" before a different main piece) that need
          their own separate rounds/time/interval values. A shared per-round structure applied to
          one list of movements (e.g. "6 rounds of: 1 minute rowing, 1 minute burpees, 1 minute
          rest") is NOT multiple parts -- that's a flat list of top-level exercises, each with its
          own "duration_seconds"; do not wrap them in a segment just to hold a shared note.
        - "movement_name" must be copied verbatim from this exact list of recognized movements (case and
          spelling matter):
          #{Movement.pluck(:name).sort.join(', ')}
          A minor spelling or plural/singular variation still counts as a match; a movement that isn't
          a clear match to anything on this list is a gap -- decline via "extractable": false instead
          of inventing a name or picking an unrelated one.
        - "distance_unit" only supports "meter", "foot", and "inch". Convert any other unit in the
          source text (miles, yards, kilometers) to meters before writing "distance" (e.g. "1 mile"
          is 1600 meters -- CrossFit's own rounded convention, not the physics-exact 1609.34) --
          never write a "distance_unit" outside those three values.
        - Only include a field when the source text specifies it; omit fields you're not confident about
          rather than guessing a value.

        #{PRESCRIPTION_CHEAT_SHEET}
      PROMPT
    end

    # Builds a prompt field-description list directly from a schema's properties, so the prompt
    # can't silently drift from the underlying model the way a hand-written description could.
    def self.field_lines(properties, indent: '  ')
      properties.map do |name, property|
        type_hint = property[:enum] ? property[:enum].map(&:inspect).join('/') : property[:type]
        "#{indent}\"#{name}\": <#{type_hint}, omit if not specified>"
      end.join(",\n")
    end

    def self.exercise_field_lines
      field_lines(WorkoutExtraction::LlmParser::EXERCISE_SCHEMA[:properties].except(:movement_name))
    end

    def self.workout_field_lines
      field_lines(WorkoutExtraction::LlmParser::WORKOUT_SCHEMA[:properties]
        .except(:extractable, :gap_reason, :segments, :exercises))
    end

    def self.segment_field_lines
      field_lines(WorkoutExtraction::LlmParser::SEGMENT_SCHEMA[:properties].except(:name, :exercises))
    end
  end
end
