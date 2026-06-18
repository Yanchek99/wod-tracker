# Decisions

## 2026-06-17: Document Programming Concepts Before Modeling Them

The app will add programming concepts in this order: intended stimulus, time
domains, strength percentages, and coach notes. Each is documented in
`programming.md` and `terminology.md` so follow-up implementation issues can be
created from a shared model rather than ad hoc choices.

Scaling is treated as individualized to the athlete, not as a set of generalist
versions the programmer authors. The programmer prescribes the workout and its
intended stimulus; adapting it to keep a specific athlete inside that stimulus is
the core problem the app aims to solve, eventually through machine learning. The
concepts modeled first are therefore the inputs that future individualized scaling
will depend on. Published CrossFit option levels (Rx, intermediate, beginner)
remain useful as source data but are not the app's scaling model.

Intended modeling direction, to be confirmed per concept in its own decision when
implemented:

- Intended stimulus is modeled as the fixed target a workout prescribes, not as
  one of several authored scale levels, so that individualized scaling can be
  evaluated against it. Per the L1/L2 guides, the stimulus is the combination of
  movements (functions), loading, time domain/frame, and volume; it is not a
  prescribed pace. Priority type (task vs time) and time domain are inputs to it,
  not the whole.
- Strength percentages are stored on the prescription, but resolving them into a
  working load requires modeling athlete maxes (1RM or training max). Until maxes
  exist, percentages are display-only.
- Coach notes are distinguished from athlete log notes. `Workout`, `Segment`, and
  `Exercise` already carry `notes`; those are coach-authored programming notes,
  while athlete notes belong with `Log`/`MovementLog`.

Cycle/week/day training blocks and parallel tracks are intentionally excluded.
Fixed multi-week blocks run counter to CrossFit's constantly-varied prescription,
and individualized scaling is intended to remove the need for separate tracks.

Rationale: documenting the concepts and their preferred mapping to existing models
first keeps later implementation aligned with current patterns (metrics,
exercises, schedules, subscriptions) and avoids parallel structures.

## 2026-06-05: Scope Exercise Positions to Their Workout Part

Top-level exercises and segments are ordered together within the workout.
Exercises inside a segment are ordered within that segment, so each segment may
restart movement positions at 1.

Rationale: segmented CrossFit workouts commonly number movements per part. A
workout-part position constraint preserves the order between unsegmented
exercises and segments, while a segment-level constraint lets independent parts
use the same child exercise positions. Existing exercise and segment positions
are renumbered within the new ordering scopes while preserving their prior
relative order.

## 2026-06-03: Store Sex-Specific Prescriptions on Metrics

Metrics support nullable `female_value` and `male_value` columns for prescribed
female/male pairs. A metric may have one unisex `value`, both sex-specific
values, or no value. It may not mix `value` with sex-specific values, and it may
not store only one side of a sex-specific pair.

Rationale: exercise prescriptions are already represented as metrics, and the
measurement determines whether the value is load, distance, height, calories, or
time. Keeping the pair on `metrics` avoids recreating a second prescription
model and supports mixed prescriptions such as wall-ball load plus target
height.

Seed definitions must be source-driven. Existing user-created workouts are not
rewritten. Seeded CrossFit workouts may include sex-specific values inline when
CrossFit Hero or daily workout source data clearly identifies the female/male
pair.
