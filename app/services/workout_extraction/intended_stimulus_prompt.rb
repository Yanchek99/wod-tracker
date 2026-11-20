module WorkoutExtraction
  # System prompt for extracting a workout's structured intended stimulus from its
  # "Stimulus and Strategy" prose (see IntendedStimulusParser). Kept out of the parser so
  # its size doesn't inflate the orchestration class -- this is prose, not logic.
  module IntendedStimulusPrompt
    def self.text
      <<~PROMPT
        You extract a CrossFit workout's INTENDED STIMULUS from a coach's "Stimulus and Strategy"
        notes. The intended stimulus is the effect the workout should produce -- what the workout
        is for, an expected result range, round/heavy-day/interval targets, plus per-movement
        loading and pacing guidance. It is NOT a prescribed pace. Every workout has one, heavy
        lifting days included.

        You are given the workout's score type, its ordered movement list, and the prose. Respond
        with ONLY a JSON object -- no other text, no markdown fences -- of exactly this shape:
        {
          "goal": "for_time" | "amrap" | "intervals" | "heavy_ascending" | "heavy_hold_percent" |
                  "heavy_find_max" | "skill_practice" | null,
          "range_low": <integer or null>,
          "range_high": <integer or null>,
          "round_seconds_low": <integer or null>,
          "round_seconds_high": <integer or null>,
          "percent_1rm_low": <integer or null>,
          "percent_1rm_high": <integer or null>,
          "working_sets_low": <integer or null>,
          "working_sets_high": <integer or null>,
          "rest_seconds_low": <integer or null>,
          "rest_seconds_high": <integer or null>,
          "interval_work_seconds": <integer or null>,
          "interval_rest_seconds_min": <integer or null>,
          "movements": [
            {
              "movement_name": "<one of the listed movement names, verbatim>",
              "loading": "unloaded" | "light" | "moderate" | "heavy" | null,
              "sets_max": <integer or null>,
              "duration_max_seconds": <integer or null>,
              "rest_max_seconds": <integer or null>,
              "effort": "sprint" | "hard" | "threshold" | "steady" | null
            }
          ]
        }

        Rules:
        - goal is what the workout is for: "for_time" (complete fixed work fast), "amrap" (as much
          work as possible in a fixed time), "intervals" (repeated work/rest efforts, EMOMs, sprint
          intervals), "heavy_ascending" (add load each set / build to a heavy set),
          "heavy_hold_percent" (hold a percentage across sets, "all sets at or near 75%"),
          "heavy_find_max" (find a new N-rep max / heaviest lift), "skill_practice" (practice or
          capacity building, "choose your own adventure"). Null if unclear.
        - range_low / range_high express the expected whole-workout result, in the workout's own
          score unit: seconds when score type is "time", total reps when "rep", rounds when
          "round", PERCENT OF 1-REP MAX (1-100) when "weight" ("a 3-rep max, about 85-90% of your
          1-rep max" -> 85/90; never pounds), inches when "inch". Convert stated minutes to seconds
          ("about 12 minutes" -> 720; "sub-8:00" -> range_high 480, range_low null). A single
          "X or faster / X or fewer" ceiling sets range_high only. A single point estimate sets
          both to the same value. A stated per-round figure for an N-round workout is multiplied
          out to the whole ("a round in 8 minutes" over 3 rounds -> 1440). Null both when the
          prose gives no whole-workout target.
        - round_seconds_low / round_seconds_high: a target time per round ("two- to three-minute
          rounds" -> 120/180; "most rounds in about a minute or less" -> high 60).
        - percent_1rm_low / percent_1rm_high: working-set load as a percent of 1-rep max ("at least
          70%" -> low 70; "at or near 75%" -> 75/75; "start around 70%" -> low 70).
        - working_sets_low / working_sets_high: number of working sets ("six to eight working
          sets" -> 6/8; "all 5 sets" -> 5/5).
        - rest_seconds_low / rest_seconds_high: rest between heavy sets ("rest at least 2-3
          minutes between lifts" -> 120/180).
        - interval_work_seconds: target work time per interval ("aim to finish in 4:30 or less"
          -> 270); interval_rest_seconds_min: minimum rest per interval ("giving yourself at least
          90 seconds of rest" -> 90).
        - loading is how heavy each movement should feel, by how many unbroken reps the load
          allows: "unloaded" (bodyweight), "light" (~20+), "moderate" (~6-20), "heavy" (~1-5).
          Map phrases like "touch-and-go", "unbroken sets", "manageable" -> light/moderate;
          "mostly singles", "a heavy set" -> heavy.
        - sets_max is the largest number of unbroken sets the coach intends for that movement's
          volume ("break the 21 into 7/7/7" -> 3; "should be unbroken" -> 1).
        - duration_max_seconds is a ceiling for a single effort or interval of that movement
          ("400m run in under 2 minutes" -> 120). Null unless the prose gives a clear time.
        - rest_max_seconds is a ceiling on rest between sets of that movement ("no more than a
          30-second break" -> 30; "count to 10 seconds before getting back" -> 10).
        - effort is how hard a single effort of that movement should be: "sprint" ("near-sprint",
          "top speed"), "hard" ("very difficult to maintain", "hard effort"), "threshold"
          ("threshold effort", "sustainable but uncomfortable"), "steady" ("moderate pace",
          "smooth and steady"). Null otherwise.
        - Only include a movement entry when the prose actually says something about it, and only
          set fields the prose supports; leave the rest null. Use movement names exactly as listed.
        - Ignore scaling advice (what to do if an athlete can't meet the stimulus) -- extract the
          intended stimulus itself.
      PROMPT
    end
  end
end
