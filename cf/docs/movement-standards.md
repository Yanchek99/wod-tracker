# Movement Standards

This file describes how the app models the numeric movement properties found in
workout prescriptions. How movements are performed and judged is out of scope.

## Measurement-Bearing Movement Properties

Some movements include numeric prescription properties that should be modeled as
metrics when present in source data.

- Wall-ball shots can prescribe ball load and target height.
- Box jumps and step-ups can prescribe box height.
- Burpees can prescribe a target height, object, or over-object standard.
- Row, ski, bike, and run movements can prescribe distance or calories.
- Weighted movements can prescribe barbell, dumbbell, kettlebell, medicine ball,
  vest, sled, sandbag, or object load.

When a movement has multiple measurable properties, model each one separately.
For example, a wall-ball shot rendered as `Wall-ball Shots (♀14lb + 9ft / ♂20lb + 10ft)`
should use one `lb` metric and one `foot` metric.

## Load-Like Measurements

`lb`, `kg`, and `weight` are load-bearing measurements. Numeric `lb` and `kg`
loads can be sex-specific. Relative loads such as `body weight` or
`1 1/2 body weight` should remain as `weight` values unless the source gives a
specific female/male numeric pair.

## Implement Count

Dumbbell and kettlebell movements can be prescribed with one or two implements,
and the difference matters: a single 50lb dumbbell thruster is easier than a
double (two-dumbbell) 50lb thruster. The prescribed load is **per implement**, so
both share the same `lb` value and differ only in how many implements are held.

Model this with the `implement_count` column on `exercises` and `movement_logs`.
It has no default: a blank count means a single implement, so only multi-implement
prescriptions set it. It renders as a `2×` prefix on the load, so a double 50lb
dumbbell thruster shows as `2×♀35lb / ♂50lb`. A count above `1` requires a load.

The field only applies to handheld implements, so the workout and log forms surface
it only for movements where `Movement#supports_implement_count?` is true. That check
uses equipment taxonomy for classified movements and falls back to dumbbell/
kettlebell names while older movement records remain unclassified.

## Movement Taxonomy

Movement taxonomy is stored as structured metadata on each movement so athlete
history and future scaling can query movement similarity without parsing names.

- Family tracks the movement's CrossFit modality: monostructural, gymnastics,
  weightlifting, or rest. Mixed modality belongs to workouts, not individual
  movements.
- Function assignments track the movement functions that make up the movement,
  following CrossFit's programming guidance to consider movement functions and
  modality: squat, hinge, vertical push, vertical pull, horizontal push,
  horizontal pull, trunk flexion, or trunk extension. Each assignment has a
  primary, secondary, or tertiary role so compound movements can preserve
  distinct phases without pretending the contribution is mathematically precise.
  Leave functions blank when the sourced function vocabulary does not apply
  cleanly.
  Source: https://www.crossfit.com/pro-coach/programming-basics-part-1
- Equipment tracks the primary implement or station when one is required; it is
  blank when no equipment or station applies.
- Skill level is a coarse basic/intermediate/advanced scale for substitution
  decisions.
External load is inferred from the weightlifting family and prescription data
rather than stored as a separate movement flag.

Substitutions are directed from an original movement to a substitute and marked
as easier, harder, or lateral. Substitutions should preserve similar primary
movement functions and range of motion when possible, while secondary functions
can help distinguish closer substitutions; movement substitution comes after
load, distance, and rep adjustments when preserving a workout stimulus.
