# CfWod::WorkoutParser — Heuristic WOD Prose → Structured Workout

Design for [issue #1675](https://github.com/matthewyanchek/wod-tracker/issues/1675), the core/largest piece of the
CrossFit.com scraper epic ([#1679](https://github.com/matthewyanchek/wod-tracker/issues/1679)). #1672 (SolidQueue +
deps), #1673 (source-identity columns + CrossFit.com program), and #1674 (`CfWod::Fetcher`/`CfWod::PageParser`, which
retrieve and extract a `CfWod::WodPage`) are already merged; this parser is the next step in the pipeline, turning a
`WodPage`'s free-form `body_text` into a built (unsaved) `Workout`.

## Scope

**In scope:**

- `CfWod::WorkoutParser` and its collaborators: turn `WodPage#body_text` into an unsaved `Workout` graph
  (`Exercise`/`Segment` children built, not persisted), following the manual-construction style already used in
  `db/seeds.rb` / `db/seeds/cf_workouts.rb`.
- Format/score classification, part splitting, per-line exercise parsing, strict movement lookup, and prescription
  (Rx) clause parsing/binding — detailed below.
- Raising `CfWod::WorkoutParser::UnparseableError` (with a `reason`) whenever the parser cannot produce a *valid*
  workout — it never returns a partial or guessed-at result.
- A real-WOD fixture corpus and full test suite for every collaborator plus end-to-end fixture parsing.

**Out of scope (left to later issues):**

- Persisting anything, or writing to the admin review queue — that's `WodImport` (#1676). This parser only raises;
  the caller (#1676 and/or the daily job in #1677) decides how to record the failure.
- Rest-day handling. `WodPage#rest_day?` is already exposed by the merged `PageParser`; the assumption here is that
  callers check it *before* invoking `WorkoutParser` — a rest day isn't an unparseable workout, it isn't a workout
  at all.
- Any changes to the `Movement` model or a general equipment/load-bearing taxonomy. That belongs to
  [#1629](https://github.com/matthewyanchek/wod-tracker/issues/1629) ("Add movement taxonomy and substitutions").
  Where this parser needs a stopgap (see Prescription Clause Assignment below), it's kept parser-local and
  explicitly commented as temporary, mirroring the existing precedent in `Movement#supports_implement_count?`
  (`app/models/movement.rb`), which does the same thing for single/double-implement loading.

## Pipeline

One entry point, six single-purpose collaborators, all flat siblings under `app/services/cf_wod/` (matching the
existing `Fetcher`/`PageParser`/`WodPage` sibling-file convention — not nested classes):

```
CfWod::WorkoutParser.call(wod_page)      # returns unsaved Workout, or raises UnparseableError
  ├── WorkoutFormatClassifier            # body_text -> { score_type:, time:, rounds:, interval:, ladder_step: }
  ├── PartSplitter                       # body_text -> [ { name:, time_seconds:, rounds:, lines: [...] }, ... ]
  ├── ExerciseLineParser                 # one line -> { movement_name:, reps:, load:, distance:, calories:, ... }
  ├── MovementLookup                     # movement_name -> Movement (strict; raises if not found)
  ├── PrescriptionClauseParser           # trailing Rx text -> [ { value:, unit:, implement: }, ... ] per sex
  └── PrescriptionClauseAssigner         # binds parsed clauses onto the right exercise line(s), or raises
```

`WorkoutParser#call`:

1. Classify format from the header sentence(s) via `WorkoutFormatClassifier` → workout-level attributes
   (`score_type`, `time`, `rounds`, `interval`, `ladder_step`).
2. Split the body into parts via `PartSplitter` (a single flat part for non-multi-part WODs).
3. For each part, parse every line via `ExerciseLineParser`, resolve each movement via `MovementLookup`, then parse
   and bind any trailing prescription (Rx) text via `PrescriptionClauseParser` + `PrescriptionClauseAssigner`.
4. Build the `Workout`/`Segment`/`Exercise` graph in memory (unsaved), following the `db/seeds.rb` idiom
   (`workout.exercises.build(...)`, `workout.segments.build(...)`). Always set `notes` to the raw `body_text`,
   regardless of parse outcome, so the source text is never lost once persisted downstream.
5. Run `.valid?` on the built graph.
6. If classification failed, any line failed to parse, any movement was unmatched, any prescription clause was
   ambiguous, or the built graph fails validation — raise `UnparseableError` with a specific, single-sentence
   `reason` describing exactly what failed (used later by #1676's review queue).

Each collaborator is independently unit-testable and can be extended in isolation as the review queue surfaces new
prose patterns — this matters because the parser is explicitly meant to grow over time (per the epic's fallback
behavior: "record the attempt... so we can extend the parser").

## Format classification

`WorkoutFormatClassifier` matches the header sentence(s) against the rules already specified in the issue:

| Prose | Result |
|---|---|
| "For time" | `score_type: :time` |
| "AMRAP in N minutes" / "As many rounds/reps as possible in N minutes" | `time: N`, `score_type: :rep` or `:round` |
| "EMOM" / "every minute on the minute for N minutes" | `rounds: N`, `time: N` (one rep block per minute) |
| Rep ladder, e.g. "21-15-9" | `interval: "21-15-9"` |
| "5-5-5" / "find a 1-rep-max <lift>" | `score_type: :weight` |

Anything not matching one of these known shapes raises `UnparseableError` immediately — no partial classification.

## Part splitting

`PartSplitter` detects two shapes already proven to occur in this app's own hand-seeded workouts
(`db/seeds/cf_workouts.rb`):

- **Sequential parts** — "Then, N rounds of the couplet:" style transitions between blocks.
- **Time-windowed parts** — explicit clock windows (e.g. "0:00–5:00:", "5:00–10:00:", as in the `260622` seed and
  the `250618` example referenced in the epic).

A body with no such markers is a single flat part (the common case). Each detected part becomes a `Segment`
(`workout.segments.build(...)`) with its own exercises; a flat body's exercises attach directly to the `Workout`
with no segment, matching `Exercise#segment` being `optional: true`.

## Exercise line parsing

`ExerciseLineParser` matches the common line grammar: `N <movement> [inline detail]` — e.g. `5 power snatches`,
`200-meter run`, `1,600-meter sled drag with a barbell front-rack carry`, `Max skin-the-cats` (bare "Max" → the
app's existing `reps: 0` sentinel for max-reps). Inline reps/distance/calories are extracted directly from the line
where present. A line that doesn't match this grammar at all fails the whole part closed (no silent skipping of
unparsed content, per the issue's "structured-or-review" fallback behavior).

## Movement lookup

`MovementLookup` normalizes the parsed movement name mechanically only — singularize, strip punctuation,
title-case (no abbreviation/synonym table, e.g. "OHS" or "power snatches" phrasing variants are not expanded) — and
looks up an existing `Movement` by exact normalized name. **No `find_or_create_by`**: an unmatched name is treated
as low-confidence and raises `UnparseableError`, sending the whole WOD to the review queue rather than risking a
garbage `Movement` row from a bad line-split. The catalog only grows when a human confirms a new name via the
review queue (#1676) — not automatically from this parser.

## Prescription clause parsing & assignment

This is the hardest part of the parser, worked through against two real examples: the `180110` legacy WOD (95/65 lb
applies to *both* the power snatch and the overhead walking lunges, but not the bodyweight rope climb) and a
multi-implement chipper (10 deadlifts / 20 pull-ups / 30 wall-ball shots / 40 box jumps / 1,000m row, with a single
trailing line encoding barbell weight, box height, *and* medicine-ball weight-plus-target-distance for three
different movements).

**`PrescriptionClauseParser`** splits the trailing prescription text into female/male clause lists. Recognizes both
legacy (`Men: 95 lb.` / `Women: 65 lb.`) and modern (`♂ 135-lb barbell` / `♀ 95-lb barbell`) prefix styles, then
splits each sex's text on commas/"and" into individual clauses (e.g. `185-lb barbell`, `20-inch box`, `14-lb
medicine ball to a 9-foot target`). A clause can carry more than one value+unit pair (weight *and* a "to a target"
distance) — both are kept together as one clause, to be bound to the same movement.

**`PrescriptionClauseAssigner`** binds each parsed clause to a movement line within the same part:

1. **Shared noun** — if the clause's implement word (box, medicine ball, sled, rope, dumbbell, kettlebell, plate...)
   appears in exactly one still-unbound movement line's own text, bind there (e.g. "box" clause → the "box jumps"
   line; "medicine ball"/"target" clause → the "wall-ball shots" line).
2. **Bare/barbell clause** (just a weight, or explicitly says "barbell") — bind to exactly one still-unbound
   movement line whose movement name is in a small parser-local `BARBELL_FAMILY_MOVEMENTS` list (snatch, clean,
   jerk, squat, deadlift, press, thruster, and lunge/carry variants whose *line text* says "overhead", "front-rack",
   or "back-rack"). This list is a stopgap — commented as pointing at #1629 for the real load-bearing taxonomy, the
   same pattern already used by `Movement::IMPLEMENT_COUNT_NAME_PATTERN` for implement counts.
3. A clause matching zero or more than one candidate under either rule → `UnparseableError` (ambiguous binding).
4. Movement lines untouched by any clause (rope climb, pull-ups, an already self-contained "1,000-meter row") stay
   bodyweight — no load/distance is set on them.

This deliberately fails closed on prescription phrasing this design didn't anticipate, rather than guessing. The
epic expects exactly this: unparseable WODs land in the review queue and extend the parser over time.

## Test corpus

Real WOD bodies fetched via the already-merged `CfWod::Fetcher`, chosen to span:

- For-time with scaled loads (have: `180110` — legacy format, snatch/lunge/rope-climb prescription binding case)
- AMRAP
- EMOM / every-N-minutes
- Rep ladder (21-15-9 style)
- Lifting / find-a-1RM
- Sequential multi-part ("Then, N rounds of...")
- Time-windowed multi-part (the `250618`-style example referenced in the epic, or the already-seeded `260622` shape)
- Rest day (have: `modern_rest_day` fixture)
- A multi-implement prescription line (the deadlift/box-jump/wall-ball chipper worked through in this design)

Specific dates are chosen and fixtures saved during implementation.

## Testing strategy

- Focused unit tests per collaborator: format classifier against header-sentence variants; part splitter against
  multi-part and flat bodies; exercise line parser against line-grammar variants; movement lookup against
  normalization edge cases; prescription clause parser/assigner against every binding scenario worked through above
  (including the deliberately-ambiguous cases that must raise).
- One integration-level test per corpus fixture, asserting the fully-built `Workout` graph (score type, time,
  rounds, segments, exercises, loads) matches the expected structure — this corpus is the acceptance-criteria
  "battle-test deliverable."
- Explicit tests that intentionally-unparseable bodies (unknown movement, ambiguous prescription clause,
  unrecognized format sentence, unmatched line grammar) raise `UnparseableError` with a specific, useful `reason`.
