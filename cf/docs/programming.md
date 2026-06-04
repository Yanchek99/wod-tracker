# Programming

## Programming Methodology

CrossFit programming combines measurable work, movement standards, and intended
stimulus. A workout prescription is more than a list of movements: it can encode
the loading, height, distance, calories, time domain, rest, interval pattern,
round structure, and score type.

When modeling CrossFit workouts, preserve the prescribed properties that affect
how the athlete performs or scores the workout. Common examples are load, reps,
distance, calories, box height, wall-ball target height, and time cap.

## Workout Structures

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
