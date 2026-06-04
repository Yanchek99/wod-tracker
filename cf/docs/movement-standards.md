# Movement Standards

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
