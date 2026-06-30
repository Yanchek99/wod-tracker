# Programming

This file describes CrossFit programming as defined by the Level 1 and Level 2
Training Guides and CrossFit Programming Basics articles (see `references.md`),
followed by the app-specific modeling and rendering conventions built on top of
that domain knowledge.

## The CrossFit Prescription

CrossFit's prescription is "constantly varied, high-intensity functional
movement" (L1 guide). Functional movements are universal motor recruitment
patterns: they move from core to extremity, are compound (multi-joint), and move
large loads over long distances quickly. Those three attributes — load, distance,
and speed — produce high power.

Intensity is defined exactly as power, and it is the independent variable most
commonly associated with maximizing the rate of return of favorable adaptation to
exercise. The breadth and depth of a program's stimulus determine the breadth and
depth of the adaptation it elicits, so the prescription of functional movement and
intensity is kept constantly varied.

## Modalities

CrossFit programming draws from three modalities (L1 guide):

- Metabolic conditioning (M): run, bike, row, jump rope.
- Gymnastics (G): air squat, pull-up, push-up, dip, handstand push-up, rope
  climb, muscle-up, press to handstand, back/hip extension, sit-up, jump, lunge.
- Weightlifting (W): deadlift, clean, press, snatch, clean and jerk, medicine-ball
  drills, kettlebell swing.

A workout's structure varies by including one, two, or three modalities.

## Variance Variables

Effective variance is planned rather than random. Any program factor can vary,
but Programming Basics emphasizes variables that affect power:

- Load: unloaded, light, moderate, or heavy. A practical coaching lens is how many
  consecutive reps the intended athlete could complete: light around 20 or more,
  moderate around 6-20, and heavy around 1-5.
- Volume: total reps, distance, rounds, and time. Practical buckets include low,
  medium, and high total reps or distance.
- Movement functions: examples include push, pull, hinge, squat, trunk flexion,
  and trunk extension.
- Modality: weightlifting, gymnastics, and monostructural/metabolic conditioning.
- Time duration: very short, short, moderate, long, and heavy-day efforts.

Variance should be broad enough to develop work capacity across time and modal
domains, but the bulk of effective CrossFit programming still supports high
relative intensity.

Movement function describes the pattern a movement contributes to a workout's
stimulus. Programming Basics gives examples such as push and pull, which may be
vertical or horizontal, hinge dominant, squat dominant, trunk flexion, and trunk
extension. This is more specific than modality: two gymnastics movements can train
different functions, and a couplet can pair complementary functions to help
athletes preserve intensity.

A movement can carry more than one function, but programming analysis should
identify the dominant function and any meaningful secondary functions. For
example, a thruster combines squat and vertical press; a clean combines hinge/pull
with a receiving position; a wall-ball shot combines squat and throw. When
scaling, preserve the intended movement function as much as possible before
changing to a different function.

## Metabolic Pathways And Time Domains

Three metabolic pathways provide the energy for all human action (L1 guide):

- Phosphagen: dominates the highest-powered activities lasting less than about 10
  seconds.
- Glycolytic: dominates moderate-powered activities lasting up to several minutes.
- Oxidative (aerobic): dominates low-powered activities lasting in excess of
  several minutes.

Total fitness requires competency in all three pathways, controlled by varying
the duration and intensity of effort. A workout's time domain — its expected
duration, commonly grouped as short, medium, or long — reflects which pathway it
targets and is one component of the intended stimulus. The L2 guide describes
short workouts such as Amanda and Elizabeth as taking about 5 minutes.

The Programming Basics articles use practical time-duration buckets for workout
planning:

- Very short: less than 5 minutes, plus heavy days.
- Short: 5-10 minutes.
- Moderate: 11-20 minutes.
- Long: more than 20 minutes.

These buckets are general coaching guidelines, not hard validation rules. The
total impact of the workout still depends on movement selection, loading,
volume, priority, transitions, fatigue, and the athlete's capacity.

## The Theoretical Template

The L1 guide presents a theoretical template for programming. Three days on and
one day off allows maximum sustainability at maximum intensity. Days are
structured by the number of modalities they include:

- Single-element days: element priority. A single effort — long, slow distance
  (M); a single high skill (G); or a single heavy lift (W). Recovery is not a
  limiting factor.
- Two-element days: task priority. A couplet repeated 3-5 rounds for time, with
  two moderately to intensely challenging elements. Work/rest interval management
  is critical.
- Three-element days: time priority. A triplet repeated for a set number of
  minutes for rotations, with three lightly to moderately challenging elements.
  Work/rest interval is a marginal factor.

## Workout Structures

CrossFit workouts are either task priority or time priority (L1 guide):

- Task priority: the work is fixed and the score is time. The task is set and the
  time varies; the workout is scored by the time to complete the prescribed work,
  as in For Time workouts like Fran and Grace.
- Time priority: the time is fixed and the score is work. The athlete is kept
  moving for a set time and scored by rotations or repetitions completed, as in
  AMRAPs, EMOMs, and interval schemes.

Common structures include:

- For time: complete the prescribed work as fast as possible.
- A one-round workout scored for time should render as `For Time`, not
  `1 round for time`.
- AMRAP: complete as many rounds or reps as possible in a fixed time.
- Fixed-rep AMRAPs such as Cindy and Mary should be logged as rounds plus
  reps and stored as total reps with a snapshotted reps-per-round value. AMRAPs
  with a max-rep station, such as Nicole, should not derive a fixed
  reps-per-round total.
- EMOM: complete prescribed work every minute on the minute.
- Interval workouts: repeated work/rest segments or fixed interval schemes such
  as Tabata.
- For load: score the heaviest successful load or aggregate prescribed lifts,
  depending on the workout.

Intervals such as `21-15-9` define rep schemes across listed movements. A rep
metric of `1` on a movement in an interval workout means the interval supplies
the reps.

## Intensity-Preserving Workout Traits

Programming Basics frames several recurring traits of effective workouts that
help preserve high relative intensity:

- Most conditioning workouts sit near the 8-15-minute range so athletes can work
  hard while accumulating useful volume.
- Complementary movement pairings, such as squat-to-press with vertical pulling,
  help athletes keep moving at high output.
- Compound, high-power movements are favored because they move large loads long
  distances quickly and produce strong training economy.
- Simple couplets and triplets are common because they keep intensity high and
  give athletes repeated exposure to each movement.
- Task-priority workouts are common because the fixed task can motivate athletes
  to finish quickly, but they demand accurate scaling so different athletes hit a
  similar intended duration.

These are trends, not exclusive rules. Variance requires periodic deviation:
heavy days, longer workouts, time-priority workouts, chippers, higher-skill
elements, and lower-power skill or accessory work can all be appropriate when
they serve the broader program.

## Programming A Single Workout

Programming Basics describes a practical single-workout workflow:

1. Define workout goals: intended duration, movement functions, loading
   parameters, format (single modality, couplet, triplet, chipper), and priority
   (task, time, or heavy day).
2. Draft the workout: choose rounds, rep scheme, specific movements, and loads.
3. Analyze and adjust: estimate movement times, round times, transitions,
   fatigue, and the expected finish time or expected rounds/reps.
4. Plan scaling: preserve loading goals, movement functions, and time-duration
   goals as much as possible for each athlete.

For task-priority workouts, estimate the time for each movement, add the time for
one round, multiply by rounds, and then add transition and fatigue time. For
time-priority workouts, estimate the time for one round including transition and
fatigue, then divide the work interval by that estimate to predict rounds or
reps. These estimates become part of the intended stimulus and guide scaling.

## Scaling: Preserve The Stimulus

The main principle of scaling is "preserve the stimulus" (L1 guide). The stimulus
is the effect produced by the specific combination of movements, time domain, and
load; aspects of that combination can be adjusted for each individual so the
workout produces relatively similar effects on each athlete regardless of physical
abilities.

For newer athletes the two factors to scale are intensity and volume (L1 guide):

- Intensity is the power an athlete generates and is modified through load, speed,
  or volume. Load is scaled first because it is the easiest way to preserve the
  stimulus relative to an athlete's capacity.
- Volume is the total work accomplished and is reduced through time, reps/rounds,
  or distance.
- Movement substitutions should preserve a similar movement function and range of
  motion. Substitute the movement only after adjusting load, distance, and reps.

To scale a workout, review its intended stimulus — movement functions, loading,
time frame, and volume (L2 guide) — and adhere to as many of those variables as
possible in light of the individual's capacity while still providing a significant
challenge. Scaling is a "moving target" as capacities change.

Programming Basics reinforces that the Rx prescription is generally written for
higher-level athletes in a gym, not for Games-level athletes. Intermediate and
beginner options can be useful general guidelines, but most athletes still need
specific scaling. Preserve the movement first when possible by scaling load,
range, reps, or distance; modify the movement only when needed, and then choose a
substitution that replicates the original function as closely as possible.

When importing canonical CrossFit workouts, scaling should be source-driven.
Recurring patterns are useful for review, but source text wins when it conflicts
with a pattern.

## Scaling Is Individualized

The published CrossFit option levels (Rx, intermediate, beginner) are a coarse,
generalist approximation of scaling — useful as source data, but not the same as
scaling a workout to a specific athlete. Because the stimulus must be preserved
for each individual, scaling is inherently per-athlete rather than a fixed set of
versions the programmer authors.

Individualizing scaling per athlete is the core problem this app aims to solve,
eventually through machine learning: given an athlete's history and a workout's
intended stimulus, design a workout variation that preserves the stimulus for that
athlete. The concepts modeled first (intended stimulus, time domains, strength
percentages and athlete maxes, coach notes) are the inputs and labels that future
individualized scaling will depend on, which is why the intended stimulus is
modeled as the fixed target rather than as one of several authored scale levels.

## Benchmark Workouts

A benchmark workout is a named, fixed-prescription workout used as a standard,
repeatable test of fitness — "the Girls" (Fran, Cindy, Grace, Diane, Elizabeth),
the Hero workouts (such as Murph), and others. The L1 guide treats Fran as "a
specific benchmark workout" and Fran's own seed text calls it "classic benchmark
that allows coaches and athletes to assess progress" (L1 guide).

Benchmarks exist to be measured against. Because the work is held constant, the
benchmark is the measurement instrument: "every time you do Fran or a specific
benchmark workout, the work is constant," so comparing a first time (T1) to a
later time (T2) cancels the work and "the difference in time is the difference in
power produced" (L1 guide). The guide concludes that "by tracking the difference
in time between workout attempts, we are looking at changes in power," and that an
athlete's collected workout data points represent "work capacity across broad time
and modal domains. This is your fitness" (L1 guide). This ties benchmarks directly
to the documented concepts of intensity-as-power and work capacity (see
`terminology.md`).

The L2 guide uses benchmarks the same way at the program level: the standard for
evaluating programming is "measurable improvement in performance markers" such as
"faster Fran times, more rounds of Cindy," and a trainer may "select specific
benchmarks to follow" (e.g. Grace, Fran, Tabata squats, JT, Fight Gone Bad, Cindy)
as recurring fitness tests (L2 guide).

Programming Basics gives the same practical program-evaluation rule: repeat
benchmarks and compare results to previous scores. Improving times, heavier
loads, and better scores indicate the program is on track; weak or stagnant
domains identify areas that may need targeted programming.

### Benchmarks And "Constantly Varied"

Constantly varied is the everyday training stimulus; the L2 guide states "Routine
is the enemy" and that variance across workouts "determines how well one is
prepared for any conceivable test of fitness" (L2 guide). Benchmarks are the
deliberate exception: they are repeated precisely because they are the measurement
instrument, not the daily stimulus. The L2 guide pairs the two explicitly —
effective long-term programming "requires reviewing what has been completed
recently in an attempt to provide new variance" and "must also allow for routine
assessment to ensure progress is occurring" (L2 guide). So a coach varies daily
training while periodically re-running fixed benchmarks to assess that the
variance is producing adaptation. The guides do not present benchmark repetition
as a violation of constantly varied; the framing here that benchmarks are the
"measurement instrument, not the everyday stimulus" is an inference drawn from the
guides' separate treatment of variance and routine assessment, and should be read
as inference rather than a direct quotation.

## Long-Term Programming

Programming Basics describes two planning strategies that sit between random
daily selection and rigid periodization:

- Look back and program ahead. Review the previous one to two weeks, identify
  neglected variables, and set a small number of goals for the upcoming week.
  Examples of gaps include missing longer workouts, moderate loads,
  monostructural movements, higher-skill elements, time-priority workouts, or
  specific movement functions.
- Template development. Use a short template, often two to six weeks, to guide
  variance across modality, duration, scheme, and priority while still leaving
  room to vary movements and loads. A generalist weekly target may include one
  heavy-focused session, one short workout, one long workout, and several classic
  couplets/triplets or single-modality sessions that support high intensity.

Templates are guardrails for coverage, not fixed specialization plans. They
should be reviewed against recent programming and adjusted to fill deficiencies.

Targeted templates can slightly increase the dose of one or two domains for about
six to eight weeks without neglecting the rest of fitness. Programming Basics
describes bookending such blocks with testing and retesting, for example a
back-squat focus that tests a 3-rep max, trains the back squat twice weekly while
maintaining broader GPP work, and then retests. This is compatible with CrossFit
when the target dose is limited and the rest of the program remains varied.

## Repeat Workouts (App Modeling)

Benchmarks are meant to recur, and repeating a workout is a first-class feature
because it is what enables score-over-time comparison. A workout's identity is its
content — its movements, loads, rep scheme, structure, and intended stimulus — and
is independent of when it is scheduled. The L1 guide's measurement argument depends
on the work being identical across attempts, so two attempts of "the same" workout
must refer to the same workout definition.

In this app's data model, a recurring benchmark is one canonical `Workout` placed
on multiple dates via multiple `Schedule` records (`posted_at`). It is not a new
duplicate `Workout` per date. The same workout scheduled five times is one
`Workout` and five `Schedule`s. The system must never create duplicate `Workout`
rows for identical content; importer and seed work can rely on this rule when
placing a benchmark on several dates. (This documents the modeling rule only; it
does not specify the deduplication mechanism — see `decisions.md`.)

This is the natural extension of the `Program`/`Schedule`/`Subscription` model
(see `terminology.md`): a `Schedule` already places one workout on a `posted_at`
date, so repeating a workout means adding `Schedule` rows for the existing
`Workout`, and an athlete's scores across those schedules form the benchmark's
progress history.

## Programming Concepts To Model First

The app already models individual workouts and places them on a calendar through
`Program`, `Schedule` (`posted_at`), and `Subscription` (owner/coach/athlete).
The next programming concepts to model build on that base. They are listed in the
intended order of implementation, and each can become its own follow-up issue.

1. Intended stimulus. The effect a workout is meant to produce. The L1 guide
   defines the stimulus as the effects of the specific combination of movements,
   time domain, and load; the L2 guide reviews a workout's intended stimulus as
   its movement functions, loading parameters, time frame, and volume of
   repetitions. It is the target a coach scales toward so the workout produces
   relatively similar effects on each athlete regardless of ability. Stimulus is
   not a prescribed pace — speed is one way an athlete modulates intensity, not
   part of the prescribed stimulus. The programmer prescribes the stimulus, and
   the app will use it as the fixed target when designing individualized workout
   variations.
2. Time domains. The expected duration of a workout, reflecting the metabolic
   pathway it targets (phosphagen, glycolytic, or oxidative) and commonly grouped
   as short, medium, or long. For a task-priority workout this is how long the
   prescribed work should take; for a time-priority workout the total time is fixed
   and the domain reflects how long each round or interval should take. Time domain
   is one component of the intended stimulus, not the whole of it, and should be
   derivable from, or stored alongside, the workout's existing `time`,
   `time_cap_seconds`, and structure fields.
3. Strength percentages. Loads prescribed relative to an athlete's capacity, such
   as a percentage of body weight (the L1 template uses loads like `thruster 50%
   of body weight`) or of a lift max (`5x3 @ 80% 1RM`). Resolving a percentage
   into a working load requires per-athlete data — body weight or a stored max
   (1RM or training max). Percentage-based loading is inherently per-athlete, so
   athlete maxes are the first piece of athlete-individualized state the app needs.
   Until that data is modeled, percentage prescriptions are display-only guidance.
4. Coach notes. Programming intent written by the coach, distinct from an
   athlete's own log notes. Coach notes carry stimulus, scaling, and strategy
   guidance. `Workout`, `Segment`, and `Exercise` already have `notes` fields;
   the modeling question is how to separate coach-authored programming notes from
   athlete-authored log notes.

Document and decide each concept's modeling approach in `decisions.md` before
implementing it. Prefer reusing existing models (metrics, exercises, schedules)
over introducing parallel structures.

## CrossFit Sex-Specific Prescription Patterns

CrossFit Hero and daily workouts commonly express female/male prescriptions as
paired values for ordinary metric measurements.

Observed source-backed patterns include:

- Box height: `♀20-inch / ♂24-inch`, and `♀24-inch / ♂30-inch` when the
  men's prescription is a 30-inch box.
- Wall-ball target height: `♀9-foot / ♂10-foot`.
- Wall-ball load: `♀14lb / ♂20lb` and heavier `♀20lb / ♂30lb`
  prescriptions.
- Weight vest/body armor: `♀14lb / ♂20lb`.
- Cardio calories can be sex-specific with the female value first, such as
  `22/30-calorie Echo bike`, `15/20-calorie Echo bike`, or
  `10/15-calorie Echo bike`.
- Machine distances can be sex-specific with the female value first, such as
  `800/1,000-meter row`, `600/750-meter row`, `400/500-meter row`,
  `200/250-meter row`, or `800/1,000-meter standing bike`.
- Run distances are commonly unisex within a workout option, but may scale by
  option level rather than by sex.
- Barbell loads have recurring CrossFit pairs, including:
  `♀35lb / ♂45lb`, `♀45lb / ♂65lb`,
  `♀55lb / ♂75lb`, `♀65lb / ♂95lb`,
  `♀75lb / ♂115lb`, `♀80lb / ♂125lb`,
  `♀95lb / ♂135lb`, `♀105lb / ♂155lb`,
  `♀125lb / ♂185lb`, `♀155lb / ♂225lb`,
  and `♀225lb / ♂315lb`.
- Multi-load barbell prescriptions preserve pair position across the sequence,
  such as `♀105/125/145lb` with `♂155/185/205lb`.
- Dumbbell and kettlebell loads also vary by workout. Examples include
  `♀35lb / ♂50lb` dumbbells and `♀35lb / ♂53lb` kettlebells.

Some workouts combine multiple sex-specific metrics on one movement. For
example, wall-ball shots can have both sex-specific ball load and sex-specific
target height, rendered as `Wall-ball Shots (♀14lb + 9ft / ♂20lb + 10ft)`.

Fight Gone Bad-style station workouts prescribe time at each station, not one
fixed rep. A station with a blank `rep` metric and a `seconds` metric should
render the duration before the movement, such as
`1:00 Wall-ball Shots (♀14lb + 9ft / ♂20lb + 10ft)`, and should not show
`1 Rep`.

Distance and calorie exercise prescriptions lead with the work metric when the
metric defines the work for that movement. For example, a Murph run segment
should render as `1600 meter Run`, not `Run (1600 meters)`. Compact
sex-specific lead prescriptions use the CrossFit shorthand order from the
source, such as `20/18 calorie Row` or `500/450 meter Row`.

## Metric Modeling Notes

Model each measurable prescription property as a metric:

- A wall-ball shot can have `rep`, `lb`, and `foot` metrics.
- A box jump can have `rep` and `inch` metrics.
- A bike or row can have `calorie` or `meter` metrics.
- A weighted movement can have `lb`, `kg`, or `weight` metrics depending on
  whether the source is numeric or relative to body weight.

Do not collapse multiple properties into one text field if they affect workout
performance or display. Use notes for instructions that are not naturally
modeled as metrics, such as partitioning guidance, tactical notes, or unusual
equipment instructions.

Use source-confirmed values instead of deriving pairs from a universal formula.
Patterns are useful for recognizing likely legacy men's Rx values, but the seed
data should only be converted when CrossFit source text confirms the pair.
