# TODO

## Normalize Round-Based Workout Scores

Treat every round-based workout score as a total rep count in storage. The
`rounds + reps` format is a user-facing convenience for entering and displaying
progress into the next round.

- Accept scores such as `20+5` when logging a round-based workout.
- Convert the entered score to total completed reps using the workout's ordered
  exercises and prescribed reps per round.
- Store the normalized total rep count.
- Display the stored score as `rounds + reps`, such as `20+5`.
- Add coverage for full rounds, partial rounds, and partial reps that cross an
  exercise boundary within the next round.
