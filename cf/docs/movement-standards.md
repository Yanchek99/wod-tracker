# Movement Standards

Movement standards are defined from the Level 1 and Level 2 Training Guides (see
`references.md`). The measurement sections describe how this app models numeric
movement properties.

## Points Of Performance, Faults, And Range Of Motion

A movement is judged by its points of performance — the criteria for proper
execution, including set-up and finish positions (L1 guide). A fault is a
deviation from a point of performance. Each foundational movement in the guides is
documented as points of performance plus common faults and corrections, and some
include a teaching progression that builds the movement up in steps.

Proper mechanics through the full range of motion come before load and speed
(mechanics, consistency, then intensity). In a workout, the range-of-motion
standards required for each movement are fixed; load and volume are what scale.

## Foundational Movements

The L1 Course teaches nine foundational movements: the air squat, front squat,
overhead squat, shoulder press, push press, push jerk, deadlift, sumo deadlift
high pull, and medicine-ball clean. It also covers four additional movements: the
pull-up, thruster, muscle-up, and snatch. The squats build on the air squat; the
presses build from the shoulder press to the push press to the push jerk; and the
deadlift is foundational to the pulling movements.

For example, the air squat — the cornerstone movement — sets up with a
shoulder-width stance; the hips descend back and down lower than the knees with
the lumbar curve maintained, knees in line with toes and heels down; and it
finishes at full hip and knee extension (L1 guide).

## Scaling Movements

When a movement is beyond an athlete's current capacity, scale load, distance, and
reps before substituting the movement. A substitution should preserve a similar
movement function and range of motion so the workout's intended stimulus is
maintained (L1/L2 guides). It is not standard to increase the volume of a
substituted or easier movement.

## Measurement-Bearing Movement Properties

Some movement standards include numeric prescription properties that should be
modeled as metrics when present in source data.

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
