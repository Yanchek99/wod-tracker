# Decisions

## 2026-06-17: Document Programming Concepts Before Modeling Them

The app will add programming concepts in this order: scales (option levels),
intended stimulus, time domains, strength percentages, coach notes, and
cycle/week/day structure. Each is documented in `programming.md` and
`terminology.md` so follow-up implementation issues can be created from a shared
model rather than ad hoc choices.

Intended modeling direction, to be confirmed per concept in its own decision when
implemented:

- Scales reuse the existing prescription model. A scale is a difficulty version
  of one workout, not an athlete record, so it should extend the current
  workout/exercise/metric prescription structures rather than introduce a
  separate prescription model.
- Strength percentages are stored on the prescription, but resolving them into a
  working load requires modeling athlete maxes (1RM or training max). Until maxes
  exist, percentages are display-only.
- Coach notes are distinguished from athlete log notes. `Workout`, `Segment`, and
  `Exercise` already carry `notes`; those are coach-authored programming notes,
  while athlete notes belong with `Log`/`MovementLog`.
- Cycle/week/day structure groups `Schedule` entries. Today a `Schedule` carries
  only `posted_at`; structured programs add an ordered cycle → week → day grouping
  layered on top of scheduling rather than replacing the dated feed.

Rationale: documenting the concepts and their preferred mapping to existing models
first keeps later implementation aligned with current patterns (metrics,
exercises, schedules, subscriptions) and avoids parallel structures. Tracks are
named in terminology for clarity but are deferred; they are not in the first
implementation set.

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
