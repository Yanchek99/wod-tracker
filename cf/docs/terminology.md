# Terminology

Core CrossFit terms are defined from the Level 1 and Level 2 Training Guides (see
`references.md`). App-specific terms describe how this app models and renders
workouts.

## CrossFit

CrossFit's prescription is "constantly varied, high-intensity functional
movement" (L1 guide). The program prepares athletes for unknown and unknowable
physical challenges by training across broad time and modal domains rather than a
fixed, specialized routine.

## Functional Movement

Functional movements are universal motor recruitment patterns: they move from
core to extremity, are compound (multi-joint), and are effective at moving large
loads over long distances quickly. Load, distance, and speed together let
functional movements produce high power (L1 guide).

## Fitness

The L1 guide defines fitness through four models: the 10 general physical skills
(cardiovascular/respiratory endurance, stamina, strength, flexibility, power,
speed, coordination, agility, balance, accuracy); the performance of athletic
tasks (the "hopper" of random physical challenges); the three metabolic pathways;
and the sickness-wellness-fitness continuum, where fitness is "super-wellness."
An athlete is as fit as they are competent across all of these.

## Intensity And Power

Intensity is defined exactly as power (L1 guide). It is the independent variable
most commonly associated with maximizing the rate of return of favorable
adaptation to exercise. Intensity is modified through load, speed, or volume, and
is relative to each athlete's capacity.

## Mechanics, Consistency, Intensity

CrossFit's charter for the best balance of safety, efficacy, and efficiency is
mechanics, consistency, then — and only then — intensity (L1 guide). Movements
must be correct and consistent before load and speed are added.

## Modalities

Workouts draw from three modalities (L1 guide): metabolic conditioning (M; run,
bike, row, jump rope), gymnastics (G; bodyweight movements such as air squats,
pull-ups, push-ups), and weightlifting (W; loaded movements such as deadlift,
clean, press, snatch). Workout structure varies by including one, two, or three
modalities.

## Metabolic Pathways

Three pathways supply energy for all human action (L1 guide): the phosphagen
pathway (highest power, under about 10 seconds), the glycolytic pathway (moderate
power, up to several minutes), and the oxidative or aerobic pathway (low power,
in excess of several minutes). Total fitness requires competency in all three.

## Foundational Movements

The L1 Course teaches nine foundational movements — the air squat, front squat,
overhead squat, shoulder press, push press, push jerk, deadlift, sumo deadlift
high pull, and medicine-ball clean — plus four additional movements: the pull-up,
thruster, muscle-up, and snatch.

## Points Of Performance And Faults

Points of performance are the criteria for proper execution of a movement,
including set-up and finish positions (L1 guide). A fault is a deviation from a
point of performance. Coaching is teaching the points of performance, seeing
deviations in real time, and correcting them.

## Intended Stimulus

The intended stimulus is the effect a workout is meant to produce. The L1 guide
defines it as the combination of movements, time domain, and load; the L2 guide
reviews it as movement functions, loading parameters, time frame, and volume of
repetitions. It is the target a coach scales toward so the workout produces
relatively similar effects on each athlete regardless of ability. Stimulus is not
a prescribed pace — speed is one way an athlete modulates intensity, not part of
the prescribed stimulus. The app will use the intended stimulus to design
individualized workout variations.

## Time Domain

The time domain is the expected duration of a workout, reflecting the metabolic
pathway it targets and commonly grouped as short, medium, or long. It is one
component of the intended stimulus, not the whole of it.

## Task Priority And Time Priority

CrossFit workouts are classified by what is fixed (L1 guide). A task-priority
workout fixes the work and scores time: the task is set, the time varies, and the
workout is scored by the time to complete it (For Time workouts such as Fran and
Grace). A time-priority workout fixes the time and scores work: the athlete is
kept moving for a set time and scored by rotations or repetitions (AMRAPs, EMOMs,
and interval schemes).

## Scaling

Scaling is adjusting a workout so a specific athlete stays inside its intended
stimulus; the principle is "preserve the stimulus" (L1 guide). It is
individualized to the athlete rather than authored as generalist versions: a scale
may change load, volume, skill demand, height/target, or time domain, but the
intended stimulus is the fixed target it preserves. Load is scaled first, then
volume, then movement substitution that keeps a similar function and range of
motion. Scaling is a "moving target" as an athlete's capacity changes (L2 guide).
Individualized scaling is the core problem the app aims to solve, eventually
through machine learning.

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
rounds, or time domain. They are a generalist starting point; true scaling is
individual to the athlete (see Scaling).

## Strength Percentage And 1RM

A strength percentage prescribes load relative to an athlete's capacity — a
percentage of body weight (as in the L1 template, e.g. `50% of body weight`) or
of a lift max (e.g. `80% 1RM`). `1RM` is a one-rep max; a training max is a
deliberately reduced max used for percentage work. Resolving a percentage into a
working load requires stored per-athlete data.

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

## Program, Schedule, And Subscription

A `Program` is a named stream of programming. A `Schedule` places one workout in
a program on a `posted_at` date. A `Subscription` connects a user to a program
with a role of owner, coach, or athlete. Coaches author programming; athletes
consume it and log their performances.

## Track

A track is a parallel programming stream within or alongside a program, such as a
competitor, fitness, or masters track. Athletes follow one track at a time. A
track is distinct from a scale: a track is a separate plan, while a scale is a
version of the same workout adjusted for an athlete.

## Coach Note

A coach note is programming guidance authored by a coach, such as stimulus,
scaling, or strategy advice. It is distinct from an athlete's log note, which
records the athlete's own performance and experience.

## Cycle, Week, And Day

A cycle (or block) is a multi-week training phase. A program's structured
schedule groups days into weeks and weeks into cycles to express progression,
rather than a flat list of dated workouts.
