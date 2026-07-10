# Open-Ended Ascending Ladders Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Parse CrossFit.com open-ended ascending-rep ladders ending in `Etc.` into the existing `Workout#ladder_step` / `Exercise` ladder model.

**Architecture:** Add one focused `CfWod::AscendingLadderInferer` service that operates on already parsed exercise-line hashes. Integrate it in `WorkoutParser` after `PartSplitter` and before exercise records are built, so the single-line parser stays single-line and prescription assignment continues to use existing code.

**Tech Stack:** Ruby 4.0.5, Rails 8.1, Minitest, existing `CfWod` parser services.

## Global Constraints

- Work in `/private/tmp/wod-tracker-1729` on branch `codex/fix-1729-ascending-ladder`.
- Preserve parser fail-closed behavior: ambiguous `Etc.` bodies must raise `CfWod::WorkoutParser::UnparseableError`.
- Recognize only a final content line that is exactly `Etc.` or `Etc`.
- Require at least two complete rungs before inferring a ladder.
- Require every complete rung to have the same movement sequence.
- Require every participating movement to imply the same positive integer `Workout#ladder_step`.
- Collapse a valid ladder to one exercise per movement using first-rung attributes.
- Do not add schema, dependencies, or UI changes.
- Use TDD: write failing tests and verify they fail before implementation.

---

### Task 1: Ascending Ladder Inference Service

**Files:**
- Create: `app/services/cf_wod/ascending_ladder_inferer.rb`
- Create: `test/services/cf_wod/ascending_ladder_inferer_test.rb`

**Interfaces:**
- Consumes: an array of hashes shaped like `{ attrs: Hash, raw_line: String }`, where `attrs` includes `:movement_name` and may include `:reps`.
- Produces: `CfWod::AscendingLadderInferer.call(parsed_lines)` returning `{ ladder_step: Integer, lines: Array<Hash> }`.
- Raises: `CfWod::WorkoutParser::UnparseableError` when the `Etc.`-terminated input cannot prove one unambiguous ascending ladder.

- [ ] **Step 1: Write failing tests**

Add `test/services/cf_wod/ascending_ladder_inferer_test.rb` with tests for a valid 3/6/9 couplet and fail-closed cases for too few rungs, movement order changes, inconsistent steps, and non-increasing reps.

- [ ] **Step 2: Run tests to verify they fail**

Run: `rvm 4.0.5@wod-tracker do bundle exec rails test test/services/cf_wod/ascending_ladder_inferer_test.rb`

Expected: FAIL/ERROR with `uninitialized constant CfWod::AscendingLadderInferer`.

- [ ] **Step 3: Implement the inference service**

Create `app/services/cf_wod/ascending_ladder_inferer.rb` with:

- `ETC = /\AEtc\.?\z/i`
- `.call(parsed_lines)`
- `#infer` that verifies `Etc.` termination, detects rung width from the first repeated movement, checks at least two complete rungs, checks movement sequence equality, checks one shared positive rep delta, and returns `{ ladder_step:, lines: first_rung }`
- a private `#raise_ambiguous` that raises `WorkoutParser::UnparseableError, 'ambiguous ascending ladder ending in Etc.'`

- [ ] **Step 4: Run tests to verify they pass**

Run: `rvm 4.0.5@wod-tracker do bundle exec rails test test/services/cf_wod/ascending_ladder_inferer_test.rb`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add app/services/cf_wod/ascending_ladder_inferer.rb test/services/cf_wod/ascending_ladder_inferer_test.rb
git commit -m "Add ascending ladder inference service"
```

### Task 2: Workout Parser Integration

**Files:**
- Modify: `app/services/cf_wod/workout_parser.rb`
- Modify: `test/services/cf_wod/workout_parser_test.rb`
- Modify: `test/services/cf_wod/workout_parser_corpus_test.rb`
- Modify only if a focused test requires it: `test/tasks/cf_wod_rake_test.rb`

**Interfaces:**
- Consumes: `CfWod::AscendingLadderInferer.call(parsed_lines)` from Task 1.
- Produces: `WorkoutParser.call(page)` returns a valid ascending-ladder workout for the CF-260710 prose shape.

- [ ] **Step 1: Write failing parser tests**

In `test/services/cf_wod/workout_parser_test.rb`, add an ambiguous `Etc.` body test that expects `UnparseableError` including `ambiguous ascending ladder`.

In `test/services/cf_wod/workout_parser_corpus_test.rb`, add a `burpee_box_jump_over` movement helper and a `260710` corpus test for:

- `score_type: rep`
- `time: 10`
- `ladder_step: 3`
- exactly two exercises
- first-rung reps on both exercises
- deadlift receives the `125/185` barbell load through existing prescription assignment

- [ ] **Step 2: Run tests to verify they fail**

Run: `rvm 4.0.5@wod-tracker do bundle exec rails test test/services/cf_wod/workout_parser_test.rb test/services/cf_wod/workout_parser_corpus_test.rb`

Expected: FAIL because `Etc.` still reaches `WorkoutParser#build_exercise_line` and raises `unrecognized exercise line: "Etc."`.

- [ ] **Step 3: Integrate ladder inference**

Modify `app/services/cf_wod/workout_parser.rb` so `build_from_body` calls a new `normalize_ladder_parts(workout, parts)` helper between `PartSplitter.call` and `build_exercise_lines`.

Add private helpers:

- `ETC_LINE = /\AEtc\.?\z/i`
- `normalize_ladder_parts(workout, parts)` that returns unchanged parts unless `flat_etc_ladder_candidate?(parts)`, otherwise parses the part's lines to `{ raw_line:, attrs: ExerciseLineParser.call(line) }`, calls `AscendingLadderInferer`, sets `workout.ladder_step`, and returns one flat part whose `lines` are the first rung's raw lines
- `flat_etc_ladder_candidate?(parts)` that requires exactly one unsegmented part and a final `Etc.`/`Etc.` line

Do not change `ExerciseLineParser`. Do not broaden the heuristic to segmented or non-final `Etc.` lines.

- [ ] **Step 4: Run focused tests to verify they pass**

Run: `rvm 4.0.5@wod-tracker do bundle exec rails test test/services/cf_wod/ascending_ladder_inferer_test.rb test/services/cf_wod/workout_parser_test.rb test/services/cf_wod/workout_parser_corpus_test.rb`

Expected: PASS.

- [ ] **Step 5: Run broader parser/rake tests**

Run: `rvm 4.0.5@wod-tracker do bundle exec rails test test/services/cf_wod test/tasks/cf_wod_rake_test.rb`

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add app/services/cf_wod/workout_parser.rb test/services/cf_wod/workout_parser_test.rb test/services/cf_wod/workout_parser_corpus_test.rb test/tasks/cf_wod_rake_test.rb
git commit -m "Parse open-ended ascending ladders from WOD prose"
```
