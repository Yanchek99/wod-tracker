# Decisions

## 2026-07-03: CrossFit.com Workout Pages Require Cache-Busting And A Retry, Not A Headless Browser

The epic's "Key findings" note (#1679) said plain HTTP GET + Nokogiri is enough to scrape
crossfit.com — true, but two non-obvious behaviors of the live site had to be confirmed
before `CfWod::Fetcher` (#1674) could rely on it, since a naive implementation following
the issue text literally would intermittently fetch an empty page:

- **There is really one canonical URL to request, not two.** `https://www.crossfit.com/workout/{YYYY}/{MM}/{DD}`
  serves the pre-redesign static template directly (`200`) for old-enough dates, and
  redirects (`301`, `Location: /{YYMMDD}`) to the modern short-slug route for newer dates.
  The exact cutover date doesn't need to be known or hardcoded — always request the
  `/workout/...` URL first and follow whichever response you get.
- **The modern `/{YYMMDD}` route is flaky, and the cause is not bot detection** (a
  dead-end initially suspected and ruled out by comparing response headers/status
  across repeated requests — there is no WAF/anti-bot signature involved, just an
  unreliable server-render). The same URL, requested twice, can return either a full
  page (400-600KB, containing `<article><span class="_text-block_HASH...">` with the
  real workout body/description/scaling as sequential `<p>` tags) or a content-less
  client-rendered shell (~130KB, no `<article>` at all) depending on the origin's
  own SSR success for that request — independent of any header or User-Agent
  difference. A fresh, unique cache-busting query parameter (plus `Cache-Control:
  no-cache`) must be applied to *every* hop, including the request made after
  following the redirect (not just the initial request) — verified by comparing dozens
  of live fetches side by side. Even with cache-busting, the shell still appears
  occasionally, so the Fetcher retries (up to 3 attempts) specifically when the
  response can't be matched to either known template.
- Confirmed real markup for both templates (via live fetch, not assumption): the old
  template's body lives in `div#wodContainer div.wod.active div.content`, with inline
  scaling after an `<hr>` as `<strong>Scaling this WOD</strong>`/`<strong>Intermediate
  Option</strong>`/`<strong>Beginner Option</strong>` paragraphs, and next/previous
  navigation as plain `<a class="next arrow">`/`<a class="prev arrow">` links. The
  modern template's `previousUrl`/`nextUrl` live in the page's embedded
  `window.__PRELOADED_STATE__` JSON instead, and its description/scaling are
  paragraphs within the same `<article>` span, marked by a leading `<strong>Stimulus
  and Strategy:</strong>` / `<strong>Scaling:</strong>` respectively.

Rationale: without the cache-busting-on-every-hop behavior, a scheduled daily scrape
job (#1677) fetching "today's" workout — always the newest, most redirect-prone date —
would intermittently import an empty workout, silently degrading the whole epic's
data quality. Documented here rather than only in code comments because it is a
durable fact about the external source, not an implementation detail, per this file's
purpose.

## 2026-06-30: Partner/Team Workouts Are A team_size Count Plus Notes

Some workouts define their work as shared across multiple athletes — a partner or
team splits a total, performs synchronized reps, alternates "one works while one
rests", or carries a buddy. The 14 such Hero workouts (City 100, Eva Strong,
Goose, Horton, Josh-O, Kev, Laura, Martin, Maxim 56, McCartney, Partner Weston,
Ryan Comas, Scooter, Timothy Helton) could not be seeded faithfully without a way
to say "this is shared work" (#1697).

The only structural addition is `workouts.team_size` (integer, nullable): `nil` is
an ordinary individual workout, `2` is a partner workout, `3+` a team of N. It
participates in the content fingerprint, so a partner version is a distinct
workout from a content-identical solo one rather than being deduped into it.

The choreography itself — total-vs-per-athlete reps, synchronized movements,
alternating/"one works one rests" stations, buddy carries — is **not** modeled as
new structured columns. It lives in `Segment#name`/`Segment#notes` and
`Exercise#notes` and renders through the existing name/notes fallbacks, mirroring
the event-triggered-penalty decision below. Seeded rep counts transcribe the
published Hero-workout numbers as written; `team_size` plus notes convey whether a
count is shared, per-athlete, or synchronized.

Logging is unchanged: a partner/team workout is logged once as the team's combined
result (its time or total reps) through the existing `Log`/`MovementLog`, with no
per-athlete schema. `team_size` is the feature that makes that score
interpretable.

Rationale: precise prescription structure is deliberately low-stakes here. The
app's individualized scaling is intended to come from machine learning over logged
history (see `programming.md`), not from a richly-structured partner prescription.
ML can normalize a combined team result by `team_size` (e.g. score-per-athlete) or
learn the team-size effect directly, so a single team log plus a `team_size`
feature is a usable training signal without splitting work per athlete. Adding one
count and reusing `Segment`/`Exercise` notes keeps these workouts seedable and
loggable today without a parallel multi-athlete model.

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

Implemented 2026-07-01 (#1684). Loads are stored canonically in **pounds**; lb/kg/pood
are input/display conventions normalized through the source-confirmed table in
`load-and-distance-equivalence.md`. The per-record `load_unit` column and enum were
removed with no replacement column: a find-a-max prescription (load-bearing, no fixed
value) is expressed as the `load: 0` sentinel, the same "unspecified" convention `reps`
and `calories` already use for their own max variants, so `Exercise#load_bearing?` and
`MovementLog#records_load?` are plain presence checks. The content fingerprint hashes the
canonical pounds value directly (no unit or marker alongside it), so the same prescription
entered/imported as lb, kg, or pood resolves to one `content_key`. A transient `load_unit=`
writer on `Exercise`/`MovementLog` is the write/import seam that normalizes an input unit
to pounds. Display unit is a `User#unit_system` preference (imperial → lb, metric → kg);
the stored magnitude and workout identity never depend on it.
Travel distance is likewise canonical **meters**, with mile/km normalized on import
(`DistanceEquivalence`); `foot`/`inch` distances and all height cases are left unchanged, and
a metric distance display toggle is deferred.

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

## 2026-06-29: Find-A-Max Prescriptions Are Weight-Scored Load Tests

A workout part that asks the athlete to find an N-rep max or build to a heavy
single is modeled as a weight-scored exercise with prescribed reps,
`duration_seconds`, a load unit, and no fixed prescribed load. The reps define
the successful attempt requirement; the duration defines the window; the empty
load with a unit means the athlete must record the load found during that window.

Single-movement max-finding workouts can derive the workout score from the logged
load once the prescribed reps are completed. Multi-movement max-finding workouts
preserve each movement's logged load and keep the workout-level score explicit,
because the published scoring rule may combine loads differently by workout.

Rationale: this reuses the existing direct prescription columns and weight score
type instead of adding a parallel prescription model. The duration belongs on the
exercise because the ML-relevant logged fact is that the athlete completed the
prescribed reps at a recorded load within that exercise's time window. It also
keeps workouts such as Dragon seedable before the app has a richer multi-component
score model.

## 2026-07-18: Variable Heavy-Day Set Schemes Are Per-Set Load Rows

Load-scored lifting prescriptions such as `Power clean 3-3-2-2-1-1-1-1 reps`
are not interval ladders. The dash-separated numbers are the reps for separate
sets, and each set needs its own logged load. A fixed-rep sequence can use one
exercise with segment `rounds`; a variable-rep sequence is modeled as one
exercise per set in order. The workout score remains load-based and is derived
from the heaviest successful set.

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
