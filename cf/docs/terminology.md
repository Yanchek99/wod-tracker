# Terminology

## Rx

Rx means the prescribed version of a workout. Rx prescriptions can include
movement standards, loads, distances, calories, target heights, box heights,
time domains, and workout structure.

When CrossFit publishes sex-specific Rx values, the female value is usually
shown first with the female symbol and the male value second with the male
symbol, for example `♀105lb / ♂155lb`.

## Scaled And Option Levels

CrossFit workouts often publish multiple versions such as Rx, intermediate, and
beginner. These are option levels, not athlete records. Option levels may change
load, reps, calories, distance, movement complexity, target height, box height,
rounds, or time domain.

Scaling should preserve the intended stimulus when possible. For example, a
scaled workout may reduce calories or load to keep the workout in the intended
time domain instead of only reducing movement difficulty.

## Sex-Specific Prescribed Values

Some CrossFit workouts prescribe different female and male values for the same
movement property. In this app those are stored as paired metric values:

- Load: `♀65lb / ♂95lb`
- Box height: `♀20-inch / ♂24-inch`
- Wall-ball target height: `♀9-foot / ♂10-foot`
- Calories: `♀22-calorie / ♂30-calorie`
- Machine distance: `♀800-meter / ♂1000-meter`

The pair belongs to the metric measurement. A wall-ball prescription with both
ball load and target height uses two metric rows: one `lb` metric and one `foot`
metric.

## Program, Schedule, And Subscription

A `Program` is a named stream of programming. A `Schedule` places one workout in
a program on a `posted_at` date. A `Subscription` connects a user to a program
with a role of owner, coach, or athlete. Coaches author programming; athletes
consume it and log their performances.

## Track

A track is a parallel programming stream within or alongside a program, such as a
competitor, fitness, or masters track. Athletes follow one track at a time. A
track is distinct from a scale: a track is a separate plan, while a scale is a
difficulty version of the same workout.

## Scaling

Scaling is adjusting a workout so a specific athlete stays inside its intended
stimulus. It is individualized to the athlete rather than authored as generalist
versions: a scale may change load, volume, skill demand, height/target, or time
domain, but the intended stimulus is the fixed target it preserves. The published
CrossFit option levels (Rx, intermediate, beginner) are a coarse generalist
approximation of scaling, useful as source data but not athlete-specific.
Individualized scaling is the core problem the app aims to solve, eventually
through machine learning.

## Task Priority And Time Priority

CrossFit workouts are classified by what is fixed. A task-priority workout fixes
the work and scores time: complete a set amount of work as fast as possible (For
Time workouts such as Fran and Grace). A time-priority workout fixes the time and
scores work: do as much work as possible in a set time (AMRAPs, EMOMs, and
interval schemes). The priority type contributes to a workout's general stimulus.

## Intended Stimulus

The intended stimulus is a general description of how a workout should be
performed, used to guide scaling. It is not pacing. It describes how movements
should be performed and what loads and volumes are appropriate so the workout
does what it is meant to do — for example, Grace's load should allow fast singles,
and Cindy should let an athlete do the pull-ups unbroken. Stimulus follows from a
workout's priority type, movements, and loads. It is the coach's tool for scaling
athletes, and the app will use it to design individualized workout variations.

## Time Domain

The time domain is the expected duration band for a workout: short (roughly under
5 minutes), medium (roughly 5 to 15 minutes), or long (roughly over 15 minutes).
It is one component of the intended stimulus, not the whole of it.

## Strength Percentage And 1RM

A strength percentage prescribes load relative to an athlete's max, such as
`80% 1RM`. `1RM` is a one-rep max; a training max is a deliberately reduced max
used for percentage work. Resolving a percentage into a working load requires a
stored athlete max.

## Coach Note

A coach note is programming guidance authored by a coach, such as stimulus,
strategy, pacing, or scaling advice. It is distinct from an athlete's log note,
which records the athlete's own performance and experience.

## Cycle, Week, And Day

A cycle (or block) is a multi-week training phase. A program's structured
schedule groups days into weeks and weeks into cycles to express progression,
rather than a flat list of dated workouts.

## Slash Notation

CrossFit sometimes writes paired values compactly without symbols:

- `800/1,000-meter row`
- `22/30-calorie Echo bike`
- `105/155-lb push press`

When the source context is female/male Rx, interpret these as female value first
and male value second.

When rendering a movement with only additional metrics, display the metrics in
parentheses after the movement name, such as `Overhead Squats (♀65lb / ♂95lb)`.
When a movement has multiple sex-specific metric properties, group them by sex,
such as `Wall-ball Shots (♀14lb + 9ft / ♂20lb + 10ft)`.
