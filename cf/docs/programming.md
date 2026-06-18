# Programming

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
2. Time domains. The expected duration band for a workout. CrossFit commonly
   groups efforts as short (roughly under 5 minutes), medium (roughly 5 to 15
   minutes), and long (roughly over 15 minutes). Time domain is one component of
   the intended stimulus, not the whole of it, and should be derivable from, or
   stored alongside, the workout's existing `time`, `time_cap_seconds`, and
   structure fields.
3. Strength percentages. Loads prescribed relative to an athlete's max, such as
   `5x3 @ 80% 1RM`. This needs both a percentage on the prescription and an
   athlete max (1RM or training max) to resolve the percentage into a working
   load. Percentage-based loading is inherently per-athlete, so athlete maxes are
   the first piece of athlete-individualized state the app needs. Until maxes are
   modeled, percentage prescriptions are display-only guidance.
4. Coach notes. Programming intent written by the coach, distinct from an
   athlete's own log notes. Coach notes carry stimulus, scaling, and strategy
   guidance. `Workout`, `Segment`, and `Exercise` already have `notes` fields;
   the modeling question is how to separate coach-authored programming notes from
   athlete-authored log notes.
5. Cycle / week / day structure. Structured programs group scheduled days into
   weeks and weeks into cycles (training blocks). Today a `Schedule` only carries
   a `posted_at` date. Structured programming adds an ordered cycle → week → day
   grouping so a program can express progression across a block rather than a
   flat calendar feed.

Document and decide each concept's modeling approach in `decisions.md` before
implementing it. Prefer reusing existing models (metrics, exercises, schedules)
over introducing parallel structures.

## Scaling Is Individualized

The CrossFit principle for scaling is "preserve the stimulus" (L1 guide). Because
the stimulus is the combination of movements, time domain, and load, aspects of
that combination can be adjusted for each individual so the workout produces
relatively similar effects on each athlete regardless of physical abilities.
Scaling is therefore individual to the athlete, not a fixed set of generalist
versions the programmer authors, and it is a "moving target" as an athlete's
capacity changes (L2 guide).

The L2 guide scales by reviewing the workout's intended stimulus — movement
functions, loading, time frame, and volume — and adhering to as many of those
variables as possible in light of the individual's capacity while still providing
a significant challenge. Load is scaled first because it most easily preserves
the stimulus; reducing volume (time, reps/rounds, distance) and substituting
movements that keep a similar function and range of motion follow. The guide's
worked examples are Amanda (9-7-5 muscle-ups and 135-lb snatches: high-skill
movements, moderate load, short time frame of about 5 minutes, low volume) and
Elizabeth (21-15-9 cleans at 135 lb and ring dips: short, moderate loading),
scaled by adjusting load, volume, or movement to fit the athlete while holding
the original intent.

The published CrossFit option levels (Rx, intermediate, beginner) are a coarse,
generalist approximation of this — useful as source data, but not the same as
scaling a workout to a specific athlete. Individualizing scaling per athlete is
the core problem this app aims to solve, eventually through machine learning:
given an athlete's history and a workout's intended stimulus, design a workout
variation that preserves the stimulus for that athlete. The concepts modeled
first (intended stimulus, time domains, strength percentages and athlete maxes,
coach notes) are the inputs and labels that future individualized scaling will
depend on, which is why the intended stimulus is modeled as the fixed target
rather than as one of several authored scale levels.

## Programming Methodology

CrossFit programming combines measurable work, movement standards, and intended
stimulus. A workout prescription is more than a list of movements: it can encode
the loading, height, distance, calories, time domain, rest, interval pattern,
round structure, and score type.

When modeling CrossFit workouts, preserve the prescribed properties that affect
how the athlete performs or scores the workout. Common examples are load, reps,
distance, calories, box height, wall-ball target height, and time cap.

## Workout Structures

CrossFit workouts are either task priority or time priority, and this split
shapes the general stimulus:

- Task priority: the work is fixed and the score is time. The athlete completes a
  set amount of work as fast as possible, as in For Time workouts like Fran and
  Grace.
- Time priority: the time is fixed and the score is work. The athlete does as
  much work as possible in a set time, as in AMRAPs, EMOMs, and interval schemes.

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

## Scaling Methodology

CrossFit scaling commonly changes several dimensions together:

- Load: barbell, dumbbell, kettlebell, medicine ball, vest, sled, or object
  weight.
- Volume: reps, rounds, calories, or distance.
- Skill demand: movement substitutions or reduced movement complexity.
- Height/target: box height, wall-ball target height, or burpee target height.
- Time domain: caps, intervals, or total workout duration.

Scaling should be source-driven when importing canonical CrossFit workouts.
Recurring patterns are useful for review, but source text wins when it conflicts
with a pattern.

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
