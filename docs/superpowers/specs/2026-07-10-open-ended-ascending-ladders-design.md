# Open-Ended Ascending Ladders Design

## Goal

Parse CrossFit.com WOD prose that spells out the first rungs of an open-ended ascending-rep ladder and ends with `Etc.` into the app's existing ascending ladder model.

## Current Problem

`CfWod::WorkoutParser` currently treats every non-prescription content line as an exercise line. For WODs such as CF-260710, the final `Etc.` line reaches `ExerciseLineParser`, returns no attributes, and raises `CfWod::WorkoutParser::UnparseableError`.

The app already has the target data model:

- `Workout#ladder_step`
- `Workout#ascending_ladder?`
- `Exercise#ladder_step_every`
- `Exercise#ladder_exempt`

The parser does not yet infer that model from prose.

## Design

Add a small parser unit under `CfWod` that receives parsed exercise-line hashes and detects one narrow shape:

- the workout body is flat, not segmented
- the final content line is exactly `Etc.` or `Etc`
- the preceding lines form at least two complete rungs
- each rung has the same movement sequence
- each movement's reps increase by the same positive integer step from rung to rung
- all participating movements imply the same `Workout#ladder_step`

When the shape matches, collapse the explicit rungs into one parsed exercise line per movement using the first rung's attributes and return the inferred ladder step. `WorkoutParser` then sets `workout.ladder_step` and builds only those collapsed exercises. Existing prescription assignment still runs against the collapsed exercise lines, so load and equipment clauses keep the current behavior.

When the final content line is `Etc.` but the preceding lines do not prove a single unambiguous ascending ladder, raise `UnparseableError` instead of treating `Etc.` as notes or guessing.

## Rejected Alternatives

Ignoring `Etc.` and importing the explicit lines only would mis-model the workout as fixed work instead of open-ended work.

Teaching `ExerciseLineParser` to parse `Etc.` would put cross-line structure into a single-line parser and still would not infer `Workout#ladder_step`.

Supporting segmented ladders, non-rep movements as ladder drivers, or mixed ladder cadences is out of scope for this issue. Those should fail closed until a real WOD requires them.

## Testing

Add unit tests for the new ladder inference class covering:

- a valid two-movement 3/6/9 ladder
- `Etc.` without enough complete rungs
- changed movement order
- inconsistent step sizes
- non-increasing reps

Add parser corpus coverage for the CF-260710 shape. The parser should produce:

- `score_type: rep`
- `time: 10`
- `ladder_step: 3`
- two exercises only
- first-rung reps for each exercise
- any prescribed barbell load applied to the deadlift through existing prescription assignment

Run the focused `CfWod` parser tests after implementation.

## Self-Review

No placeholders remain. The scope is intentionally limited to flat, rep-counted, `Etc.`-terminated ladders. The design matches the existing fail-closed parser philosophy in `cf/docs/decisions.md`.
