module WorkoutExtraction
  # The system prompt sent to the LLM for workout-text extraction (see LlmParser). Kept out of
  # LlmParser so its size doesn't inflate the orchestration class -- this is prose, not logic.
  module SystemPrompt
    PRESCRIPTION_CHEAT_SHEET = <<~CHEATSHEET.freeze
      Common notation:
      - "21-15-9 reps for time" = an ascending/descending rep ladder across rounds (interval).
      - Load-scored lifting schemes like "Power clean 3-3-2-2-1-1-1-1 reps" are sets for load,
        not intervals; each set needs its own logged load.
      - "5 RFT" = 5 rounds for time (rounds: 5, score_type: "round" is wrong here -- use "time").
      - "AMRAP 20" = as many rounds/reps as possible in 20 minutes (time: 1200; score_type "round" if
        scored by full rounds, "rep" if scored by total reps including partial rounds).
      - "EMOM 10" = every minute on the minute for 10 minutes; a fixed-work-per-interval workout.
      - "♀95lb / ♂135lb" (or "Women: 95lb, Men: 135lb") explicitly labels each value -- use the
        symbol/label, not position, to assign female_load/male_load. A bare, unlabeled split like
        "65/95" is female/male (female_load/male_load) -- female value first, male value second.
        A single number applies to both sexes equally via "load".
      - A box height for box jumps or box step-ups (e.g. "♀ 20-inch box / ♂ 24-inch box", or a bare
        "24/20 in") is a distance in inches, never a load: use female_distance/male_distance (or a
        single "distance") with distance_unit "inch". Do not put box height in female_load/male_load
        even though it looks like a sex-split load pattern.
      - A shuttle run has a per-rep distance, stated as one leg out and back ("One shuttle run is
        25 feet down and 25 feet back" -> "distance": 50, "distance_unit": "foot"; sum the legs).
        Set it on the Shuttle Run exercise even when the length is in a separate sentence, and
        keep the rep count ("10 shuttle runs" -> reps 10).
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
              "name": "<string, optional>",
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
        - "name" is the workout's own title -- use it whenever the source text has a title line
          above the prescription: a hero-workout name ("Murph"), a numbered series/event title
          ("Community Cup Workout 3", "Open Workout 25.1"), or a quoted nickname ("Tank Top Time").
          Copy it verbatim into "name". Omit "name" only when there is genuinely no such title line;
          never use a prescription/rep-scheme line, a movement line, or a section heading like
          "Stimulus and Strategy" as the name. The app supplies a date-based fallback when "name"
          is absent.
        - "score_type" must be exactly one of: #{Metric.workout_measurements.join(', ')}. Use "time" for
          for-time workouts, including rounds-for-time (e.g. "5 RFT") -- these are scored by elapsed
          time, not round count. Use "rep" for AMRAP/max-rep workouts scored by total reps, "round"
          only for AMRAP-style workouts actually scored by rounds completed, "weight" for max-load
          workouts, "calorie" for calorie-based workouts.
        - "interval" holds a rep scheme like "21-15-9" when the workout is an ascending or descending
          conditioning rep ladder across rounds; leave it out otherwise.
        - For load-scored lifting set schemes (e.g. "Back squat 5-5-5-5-5 reps" or
          "Power clean 3-3-2-2-1-1-1-1 reps"), use "score_type": "weight" and do not set
          "interval". When all sets use the same reps, set top-level "rounds" to the set count and
          include one exercise with that reps value. When reps vary by set, omit "rounds" and list
          one exercise per set in order, each with that set's reps.
        - For an exercise driven by an interval scheme (the workout's own "interval", or its
          segment's "interval_scheme"), set that exercise's plain "reps" -- or plain "calories" for
          a calorie-scored movement like a Calorie Row -- to 1, a structural placeholder, never the
          literal first-round number (e.g. not 21 for "21-15-9"), and never as "female_calories"/
          "male_calories" -- a placeholder is never sex-specific, even if the workout has
          sex-specific values elsewhere (e.g. a load on a different movement). The real per-round
          values come from the interval scheme itself, not from a stored count on the exercise.
        - An exercise prefixed "Max"/"Maximum" (e.g. "Max chest-to-bar pull-ups", "Max power
          snatches") inside a timed AMRAP window is scored by whatever reps the athlete completes,
          not a fixed count -- set that exercise's "reps" to 0, the app's own "max reps" sentinel.
          Never 1: that is the interval-placeholder value from the rule above, and it does NOT
          apply here -- a "Max" movement has no per-round count to stand in for. Apply this in
          every segment that has a "Max" movement, however many there are: a workout of three
          4-minute windows (max power snatches, then max overhead squats, then max squat snatches),
          each also holding 10 shuttle runs and 21 toes-to-bars, gets "reps": 0 on the
          snatch/overhead-squat exercise of all three segments while the shuttle runs stay 10 and
          the toes-to-bars stay 21.
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
        - IMPORTANT, and easy to get wrong -- contrast this with the case directly above: when an
          outer round count instead wraps several already-distinct, separately-timed parts (e.g.
          "2 rounds for total reps of:" followed by three different "On a 3-minute clock:" blocks,
          each with its own movements), those blocks DO need their own segments (per the rule
          above) AND the round count applies to the whole group of them together. There is no
          schema field for "repeat this group of segments N times" -- the only way to represent it
          is to emit the same segment objects again, in the same order, N times total in the
          "segments" array. Concretely: "2 rounds for total reps of: [3-min run+pull-up block]
          Rest 1 minute [3-min run+push-up block] Rest 1 minute" is 4 segments in this exact
          order -- [run+pull-up], [run+push-up], [run+pull-up] (repeated), [run+push-up]
          (repeated) -- never 2. Do not drop the repeat or emit only one pass through the group.
        - A segment's "name" is a short label copied verbatim from the source's own heading for
          that part -- "Part A", "Buy-in", "On a 3-minute clock", "0:00-5:00". Omit "name"
          entirely when the source gives the part no heading of its own. Never invent a name that
          summarizes the part's movements or scheme (NOT "Block 1: Run + Max Pull-ups", NOT
          "3-minute AMRAP") -- those movements are already listed in the segment's "exercises".
        - A "Rest N minutes" (or "Rest N minute") line after a timed segment's exercises is that
          segment's own "rest_seconds" -- this still applies to the LAST part in a repeated group
          (the rule above), even though the same rest also precedes the next repetition of the
          first part. Do not omit "rest_seconds" on a segment just because it happens to be last.
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
        - A movement's "distance" counts as specified even when its length sits in a separate
          sentence, not inline with the rep count -- still set "distance"/"distance_unit" on that
          exercise. Most common case: a shuttle run given as one leg out and back -- "One shuttle
          run is 25 feet down and 25 feet back" means every "Shuttle Run" exercise gets
          "distance": 50 (the two legs summed), "distance_unit": "foot", plus its rep count.
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
      field_lines(WorkoutExtraction::LlmParser.exercise_schema[:properties].except(:movement_name))
    end

    def self.workout_field_lines
      field_lines(WorkoutExtraction::LlmParser.workout_schema[:properties]
        .except(:extractable, :gap_reason, :segments, :exercises))
    end

    def self.segment_field_lines
      field_lines(WorkoutExtraction::LlmParser.segment_schema[:properties].except(:name, :exercises))
    end
  end
end
