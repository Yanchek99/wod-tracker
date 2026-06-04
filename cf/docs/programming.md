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
- AMRAP: complete as many rounds or reps as possible in a fixed time.
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

- Box height: `♀ 20-inch / ♂ 24-inch`, and `♀ 24-inch / ♂ 30-inch` when the
  men's prescription is a 30-inch box.
- Wall-ball target height: `♀ 9-foot / ♂ 10-foot`.
- Wall-ball load: `♀ 14-lb / ♂ 20-lb` and heavier `♀ 20-lb / ♂ 30-lb`
  prescriptions.
- Weight vest/body armor: `♀ 14-lb / ♂ 20-lb`.
- Cardio calories can be sex-specific with the female value first, such as
  `22/30-calorie Echo bike`, `15/20-calorie Echo bike`, or
  `10/15-calorie Echo bike`.
- Machine distances can be sex-specific with the female value first, such as
  `800/1,000-meter row`, `600/750-meter row`, `400/500-meter row`,
  `200/250-meter row`, or `800/1,000-meter standing bike`.
- Run distances are commonly unisex within a workout option, but may scale by
  option level rather than by sex.
- Barbell loads have recurring CrossFit pairs, including:
  `♀ 35-lb / ♂ 45-lb`, `♀ 45-lb / ♂ 65-lb`,
  `♀ 55-lb / ♂ 75-lb`, `♀ 65-lb / ♂ 95-lb`,
  `♀ 75-lb / ♂ 115-lb`, `♀ 80-lb / ♂ 125-lb`,
  `♀ 95-lb / ♂ 135-lb`, `♀ 105-lb / ♂ 155-lb`,
  `♀ 125-lb / ♂ 185-lb`, `♀ 155-lb / ♂ 225-lb`,
  and `♀ 225-lb / ♂ 315-lb`.
- Multi-load barbell prescriptions preserve pair position across the sequence,
  such as `♀ 105/125/145-lb` with `♂ 155/185/205-lb`.
- Dumbbell and kettlebell loads also vary by workout. Examples include
  `♀ 35-lb / ♂ 50-lb` dumbbells and `♀ 35-lb / ♂ 53-lb` kettlebells.

Some workouts combine multiple sex-specific metrics on one movement. For
example, wall-ball shots can have both sex-specific ball load and sex-specific
target height.

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
