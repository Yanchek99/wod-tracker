# Decisions

## 2026-06-21: Model Event-Triggered Penalties as a Named Segment

Some workouts attach work that is triggered by an event rather than sequenced
into the round — for example crossfit.com/260620, a 1,600-meter loaded carry
where "every time you stop, complete 15 bent-over rows before resuming." The
number of penalty reps is not known when the workout is programmed; it depends on
how the athlete performs.

This reuses the existing `Segment`, with no schema change. The penalty movement(s)
live in a segment whose `name` is the trigger phrase (e.g. "Every time you stop");
the exercises carry the per-occurrence quantum as `reps` (15). The segment renders
through the existing name fallback as the trigger phrase followed by its movements.
When logging, the athlete records the total reps actually completed on the movement
log, so the open-ended volume is captured per performance.

Rationale: the penalty is genuinely a grouped unit of work, which is what
`Segment` already represents, and a named segment already renders and orders
correctly — so no new column or "penalty"/"condition" concept is needed.

## 2026-06-18: Prescribed Load Identity Is A Canonical Magnitude, Not (Value, Unit)

Decision recorded for a follow-up issue; not yet implemented.

CrossFit expresses a single prescribed load in whichever unit suits the audience —
pounds, kilograms, or pood — and these are display conventions for the same
prescription, not different prescriptions. The current model stores load as a
value plus a `load_unit` enum on the exercise, which folds the display unit into
the load's identity. That is the wrong layer: the prescribed *magnitude* is the
identity, and lb/kg/pood are presentations derived from it.

The equivalences are rounded conventions tied to standard implements, not exact
arithmetic. CrossFit kettlebell prescriptions are the standard 16/24/32 kg
implements, labeled 1/1.5/2 pood and (approximately) 35/53/70 lb; 2 pood is
exactly ~72 lb but is published as 70 lb. Barbell Rx similarly publishes pairs
such as 95 lb / 43 kg even though 43 kg is ~94.8 lb. So load cannot be canonicalized
by physics (converting everything to grams would split 95 lb from 43 kg, which is
backwards) — canonicalization must follow CrossFit's published standard-equivalence
table.

Direction (to be confirmed in the implementing issue): store load as one canonical
magnitude and treat lb/kg/pood as input/display formats normalized through a
source-confirmed CrossFit standard-equivalence table; display unit becomes a
presentation/user-preference concern rather than part of load identity. A heavier
alternative is a first-class `StandardLoad` concept that exercises reference for Rx
loads, with arbitrary/user loads keeping a raw magnitude.

The exact equivalence table (pood and lb/kg Rx pairs) must be source-confirmed
from the L1/L2 guides and CrossFit prescriptions before encoding, per
`OVERVIEW.md`; the specific values above are stated as illustration and are not yet
source-verified.

Rationale: this is a prerequisite for content-based workout deduplication (see the
repeat/benchmark decision below). A content fingerprint can only guarantee
uniqueness up to its canonical form, so if the same prescription can be stored as
both 95 lb and 43 kg the fingerprint will create duplicate `Workout` rows. Fixing
load identity first makes the fingerprint reliable. Scoped to its own issue to keep
the idempotency schema/seed change (#1673) small.

## 2026-06-18: Repeat/Benchmark Workouts Are One Workout On Many Schedules

A repeated or benchmark workout (Fran, Cindy, Grace, Murph, etc.) is modeled as a
single canonical `Workout` placed on multiple dates through multiple `Schedule`
records (`posted_at`). It is not a new duplicate `Workout` per date. The same
workout scheduled five times is one `Workout` and five `Schedule`s, and the
system must not create duplicate `Workout` rows for identical content. Workout
identity is content-based — defined by its movements, loads, rep scheme,
structure, and intended stimulus — and is independent of when it is scheduled.

Rationale: a benchmark is a measurement instrument. The L1 guide's argument that
comparing two attempts of a workout reports the change in an athlete's power and
work capacity ("This is your fitness") only holds when the work is constant across
attempts, so both attempts must reference the same workout definition. Treating
each scheduled occurrence as a distinct `Workout` would fragment a benchmark's
history and break score-over-time comparison. One `Workout` reused across many
`Schedule` (`posted_at`) rows is the direct extension of the existing
`Program`/`Schedule`/`Subscription` model — a `Schedule` already places one
workout on a date — so repeating a workout means adding schedules, not workouts,
and an athlete's logs across those schedules form the benchmark's progress
history.

Deduplication mechanism: each `Workout` carries a `content_key`, a fingerprint of
its scoring scheme and ordered parts (with a unique index). On save, a workout whose
content matches an existing one keeps a nil key, and `Workout#absorb_duplicate!`
folds its schedules (deduped on program + `posted_at`) and logs into the existing
canonical workout, then deletes the duplicate. So editing or importing a workout
into an existing one's content yields a single workout, with the edit redirected to
the survivor. Free-text notes are excluded from the fingerprint; canonical load
identity (lb/kg/pood) is the remaining gap (see #1684).

## 2026-06-20: Store Movement Taxonomy On Movements

Movement metadata is stored directly on `Movement` using one primary family,
one equipment class, one skill level, and a set of component movement patterns.
Substitutions live in a directed join table with an easier/harder/lateral
direction.

Rationale: future scaling needs queryable movement similarity and directed
substitution options before it can choose individualized variations. Family,
equipment, and skill level stay scalar, while patterns are multi-valued so
compound movements can expose each meaningful component without a generic mixed
pattern. External load is inferred from the weightlifting family and
equipment/prescription data rather than duplicated as a movement-level boolean.

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
