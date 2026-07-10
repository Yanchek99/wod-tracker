# Task 2 Report: Workout Parser Integration

## What I Implemented

- Added `WorkoutParser::ETC_LINE` and normalized a single unsegmented body part ending in exact `Etc.` before building exercises.
- The normalization parses every raw line, calls `CfWod::AscendingLadderInferer`, sets `Workout#ladder_step`, and retains only the inferred first-rung raw lines.
- Prescription assignment still receives the resulting exercise lines, so existing barbell clauses apply to the collapsed deadlift line.
- Added an ambiguous `Etc.` parser regression test and a CF-260710 corpus test covering the 3-rep ladder, both first-rung exercises, and the 125/185 deadlift prescription.

## TDD RED Command

Command attempted after writing the parser tests:

```sh
rvm 4.0.5@wod-tracker do bundle exec rails test test/services/cf_wod/workout_parser_test.rb test/services/cf_wod/workout_parser_corpus_test.rb
```

Output (exit 1):

```text
/Users/matthewyanchek/.rvm/scripts/rvm:29: operation not permitted: ps
/Users/matthewyanchek/.rvm/scripts/rvm: line 29: /bin/ps: Operation not permitted
RVM not loaded, aborting.
```

The intended RED failure was `unrecognized exercise line: "Etc."`, because the parser had not yet normalized an `Etc.` ladder. The sandbox blocked RVM before Rails could load.

## GREEN, Focused, And Broader Verification

Focused command attempted after the implementation:

```sh
rvm 4.0.5@wod-tracker do bundle exec rails test test/services/cf_wod/ascending_ladder_inferer_test.rb test/services/cf_wod/workout_parser_test.rb test/services/cf_wod/workout_parser_corpus_test.rb
```

Broader command attempted:

```sh
rvm 4.0.5@wod-tracker do bundle exec rails test test/services/cf_wod test/tasks/cf_wod_rake_test.rb
```

Both commands exited 1 before Rails loaded with the same sandbox block:

```text
/Users/matthewyanchek/.rvm/scripts/rvm:29: operation not permitted: ps
/Users/matthewyanchek/.rvm/scripts/rvm: line 29: /bin/ps: Operation not permitted
RVM not loaded, aborting.
```

`git diff --check` completed successfully.

## Files Changed

- `app/services/cf_wod/workout_parser.rb`
- `test/services/cf_wod/workout_parser_test.rb`
- `test/services/cf_wod/workout_parser_corpus_test.rb`
- `.superpowers/sdd/task-2-report.md`

## Self-Review Findings

- The heuristic is limited to exactly one unsegmented part with a final exact `Etc.` line.
- Segmented bodies and non-final `Etc.` lines continue through the existing parser unchanged.
- The raw first-rung lines are passed back into the existing exercise and prescription pipeline.

## Concerns

- The required Rails test commands could not run inside this sandbox because RVM invokes `/bin/ps`. They need to be run outside the sandbox.
